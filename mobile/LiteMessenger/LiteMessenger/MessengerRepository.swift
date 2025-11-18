//
//   MessengerRepository.swift
//  LiteMessenger


import Foundation


import SwiftUI

final class MessengerRepository {
    private var credentials: [String: (MessengerUser, String)] = [:]
    private var chats: [UUID: ChatThread] = [:]
    
    init() {
        let jordan = MessengerUser(id: UUID(), name: "User One", email: "user1@email.com", role: "Product Designer", status: "Available", bio: "Design-driven communicator.", color: .indigo)
        let maria = MessengerUser(id: UUID(), name: "Maria Alvarez", email: "maria@studio.com", role: "iOS Engineer", status: "Working remotely", bio: "Building flows and shipping them fast.", color: .pink)
        let andrew = MessengerUser(id: UUID(), name: "Andrew Kim", email: "andrew@studio.com", role: "QA Lead", status: "Reviewing builds", bio: "Testing saves future headaches.", color: .orange)
        let laila = MessengerUser(id: UUID(), name: "Laila Rahman", email: "laila@studio.com", role: "Marketing", status: "In meetings", bio: "Stories that connect.", color: .green)
        
        credentials[jordan.email.lowercased()] = (jordan, "123456")
        credentials[maria.email.lowercased()] = (maria, "password")
        credentials[andrew.email.lowercased()] = (andrew, "password")
        credentials[laila.email.lowercased()] = (laila, "password")
        
        let chat1 = ChatThread(
            id: UUID(),
            participants: [jordan, maria],
            messages: [
                MessageModel(sender: maria, text: "Morning! Did you see the new design review?", timestamp: Date().addingTimeInterval(-3600)),
                MessageModel(sender: jordan, text: "Yep, I left some notes for the animation states.", timestamp: Date().addingTimeInterval(-3500)),
                MessageModel(sender: maria, text: "Perfect, I’ll push another build after lunch.", timestamp: Date().addingTimeInterval(-3200))
            ]
        )
        let chat2 = ChatThread(
            id: UUID(),
            participants: [jordan, andrew],
            messages: [
                MessageModel(sender: andrew, text: "I caught two regressions in the compose screen.", timestamp: Date().addingTimeInterval(-7200)),
                MessageModel(sender: jordan, text: "Thanks! I can patch them today.", timestamp: Date().addingTimeInterval(-7150))
            ]
        )
        let chat3 = ChatThread(
            id: UUID(),
            participants: [jordan, laila],
            messages: [
                MessageModel(sender: laila, text: "Campaign copy is ready for review.", timestamp: Date().addingTimeInterval(-10800)),
                MessageModel(sender: jordan, text: "Awesome, I’ll plug it into the prototype tonight.", timestamp: Date().addingTimeInterval(-9800))
            ]
        )
        chats[chat1.id] = chat1
        chats[chat2.id] = chat2
        chats[chat3.id] = chat3
    }
    
    func authenticate(email: String, password: String) -> MessengerUser? {
        guard let entry = credentials[email.lowercased()], entry.1 == password else { return nil }
        return entry.0
    }
    
    func createAccount(name: String, email: String, password: String) -> MessengerUser? {
        guard credentials[email.lowercased()] == nil else { return nil }
        let newUser = MessengerUser(
            id: UUID(),
            name: name,
            email: email,
            role: "New Member",
            status: "Online",
            bio: "Loving conversations.",
            color: .blue
        )
        credentials[email.lowercased()] = (newUser, password)
        return newUser
    }
    
    func loadChats(for user: MessengerUser) -> [ChatThread] {
        chats.values
            .filter { chat in chat.participants.contains { $0.id == user.id } }
            .sorted { ($0.messages.last?.timestamp ?? .distantPast) > ($1.messages.last?.timestamp ?? .distantPast) }
    }
    
    func send(message: String, from sender: MessengerUser, in chatID: UUID) -> [ChatThread] {
        guard var chat = chats[chatID] else { return Array(chats.values) }
        let newMessage = MessageModel(sender: sender, text: message, timestamp: Date())
        chat.messages.append(newMessage)
        chats[chatID] = chat
        return loadChats(for: sender)
    }
    
    func searchUsers(query: String, excluding current: MessengerUser) -> [MessengerUser] {
        guard !query.isEmpty else { return [] }
        let lower = query.lowercased()
        return Array(credentials.values
            .map { $0.0 }
            .filter { $0 != current }
            .filter { $0.name.lowercased().contains(lower) || $0.email.lowercased().contains(lower) }
            .prefix(5))
    }
    
    func startChat(between current: MessengerUser, and other: MessengerUser) -> ChatThread {
        if let existing = chats.values.first(where: { chat in
            chat.participants.contains(where: { $0.id == current.id }) &&
            chat.participants.contains(where: { $0.id == other.id })
        }) {
            return existing
        }
        let newChat = ChatThread(id: UUID(), participants: [current, other], messages: [])
        chats[newChat.id] = newChat
        return newChat
    }
    
    func updateProfile(_ updated: MessengerUser) {
        if let entry = credentials.first(where: { $0.value.0.id == updated.id }) {
            credentials.removeValue(forKey: entry.key)
            credentials[updated.email.lowercased()] = (updated, entry.value.1)
        } else {
            credentials[updated.email.lowercased()] = (updated, "123456")
        }
        for key in chats.keys {
            var chat = chats[key]!
            chat.participants = chat.participants.map { $0.id == updated.id ? updated : $0 }
            chat.messages = chat.messages.map { message in
                if message.sender.id == updated.id {
                    return MessageModel(id: message.id, sender: updated, text: message.text, timestamp: message.timestamp)
                }
                return message
            }
            chats[key] = chat
        }
    }
}
