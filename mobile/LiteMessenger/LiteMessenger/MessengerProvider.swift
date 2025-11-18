//
//  MessengerProvider.swift
//  LiteMessenger
//

import Foundation
import SwiftUI

final class MessengerProvider: MessengerService {
    private let client: NetworkClient
    private var token: String?
    private var me: MessengerUser?
    private var socket: WebSocketManager?
    private var streamContinuation: AsyncStream<MessageModel>.Continuation?

    init(baseURL: URL) {
        self.client = NetworkClient(baseURL: baseURL)
    }

    // MARK: - Auth

    func authenticate(email: String, password: String) async throws -> MessengerUser {
        struct Payload: Encodable { let email: String; let password: String }
        let user: UserDTO = try await client.request(
            "/auth/login", method: "POST", body: Payload(email: email, password: password)
        )
        token = user.token
        client.setAuthToken(token)
        let domain = MessengerUser(dto: user)
        me = domain
        return domain
    }

    func createAccount(name: String, email: String, password: String) async throws -> MessengerUser {
        struct Payload: Encodable { let name: String; let email: String; let password: String }
        let user: UserDTO = try await client.request(
            "/auth/signup", method: "POST", body: Payload(name: name, email: email, password: password)
        )
        token = user.token
        client.setAuthToken(token)
        let domain = MessengerUser(dto: user)
        me = domain
        return domain
    }

    // MARK: - Threads

    func loadChats(for user: MessengerUser) async throws -> [ChatThread] {
        let threads: [ThreadDTO] = try await client.request("/threads")
        return threads.map(ChatThread.init(dto:))
    }

    func startChat(between current: MessengerUser, and other: MessengerUser) async throws -> ChatThread {
        struct Payload: Encodable { let participantId: UUID }
        let dto: ThreadDTO = try await client.request("/threads", method: "POST",
                                                      body: Payload(participantId: other.id))
        return ChatThread(dto: dto)
    }

    // MARK: - Messages

    func send(message: String, from sender: MessengerUser, in chatID: UUID) async throws -> [ChatThread] {
        struct Payload: Encodable { let text: String }
        let _: Empty = try await client.request("/threads/\(chatID.uuidString)/messages",
                                                method: "POST", body: Payload(text: message))
        // Refresh list after send (depends on your app needs)
        return try await loadChats(for: sender)
    }

    // MARK: - People

    func searchUsers(query: String, excluding current: MessengerUser) async throws -> [MessengerUser] {
        guard !query.isEmpty else { return [] }
        let users: [UserDTO] = try await client.request("/users/search",
                                                        query: [URLQueryItem(name: "q", value: query)])
        return users.map(MessengerUser.init(dto:)).filter { $0.id != current.id }
    }

    // MARK: - Profile

    func updateProfile(_ updated: MessengerUser) async throws {
        struct Payload: Encodable {
            let name: String; let role: String; let status: String; let bio: String; let colorHex: String
        }
        let hex = "#FF7A00FF" // TODO: convert from updated.color if needed
        let payload = Payload(name: updated.name, role: updated.role, status: updated.status,
                              bio: updated.bio, colorHex: hex)
        let _: Empty = try await client.request("/me", method: "PATCH", body: payload)
        me = updated
    }

    // MARK: - Realtime

    func connectRealtime(for user: MessengerUser) async {
        guard let token else { return }
        // TODO: set your websocket url
        let wsURL = URL(string: "wss://api.yourserver.com/realtime")!
        let mgr = WebSocketManager(url: wsURL)
        mgr.connect(token: token)
        self.socket = mgr
    }

    func disconnectRealtime() {
        socket?.disconnect()
        socket = nil
        streamContinuation?.finish()
        streamContinuation = nil
    }

    func messageStream() -> AsyncStream<MessageModel> {
        guard let socket else {
            return AsyncStream { cont in cont.finish() }
        }
        let upstream = socket.stream()
        return AsyncStream { (cont: AsyncStream<MessageModel>.Continuation) in
            self.streamContinuation = cont
            Task {
                for await dto in upstream {
                    // Map DTO to domain; you might need to fetch sender user if not present
                    let sender = (self.me ?? .placeholder)
                    let model = MessageModel(dto: dto, sender: sender)
                    cont.yield(model)
                }
                cont.finish()
            }
        }
    }
}
