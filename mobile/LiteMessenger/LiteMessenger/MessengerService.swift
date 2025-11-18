//
//  MessengerService.swift
//  LiteMessenger

import Foundation
import SwiftUI

/// Common contract both local repository and remote provider will implement.
protocol MessengerService {
    // Auth
    func authenticate(email: String, password: String) async throws -> MessengerUser
    func createAccount(name: String, email: String, password: String) async throws -> MessengerUser

    // Threads
    func loadChats(for user: MessengerUser) async throws -> [ChatThread]
    func startChat(between current: MessengerUser, and other: MessengerUser) async throws -> ChatThread

    // Messages
    func send(message: String, from sender: MessengerUser, in chatID: UUID) async throws -> [ChatThread]

    // People
    func searchUsers(query: String, excluding current: MessengerUser) async throws -> [MessengerUser]

    // Profile
    func updateProfile(_ updated: MessengerUser) async throws

    // Live updates (optional but recommended)
    func connectRealtime(for user: MessengerUser) async
    func disconnectRealtime()
    func messageStream() -> AsyncStream<MessageModel>
}
