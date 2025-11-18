//
//  DTOs.swift
//  LiteMessenger

import Foundation
import SwiftUI

// MARK: - DTOs (match your API)

struct UserDTO: Codable {
    let id: UUID
    let name: String
    let email: String
    let role: String
    let status: String
    let bio: String
    let colorHex: String
    // optional auth token when logging in / signing up
    let token: String?
}

struct MessageDTO: Codable, Identifiable {
    let id: UUID
    let senderId: UUID
    let text: String
    let timestamp: Date
}

struct ThreadDTO: Codable, Identifiable {
    let id: UUID
    let participants: [UserDTO]
    let messages: [MessageDTO]
}

// MARK: - Mapping to Domain

extension MessengerUser {
    init(dto: UserDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            email: dto.email,
            role: dto.role,
            status: dto.status,
            bio: dto.bio,
            color: Color(hex: dto.colorHex) ?? .indigo
        )
    }
}

extension MessageModel {
    init(dto: MessageDTO, sender: MessengerUser) {
        self.init(id: dto.id, sender: sender, text: dto.text, timestamp: dto.timestamp)
    }
}

extension ChatThread {
    init(dto: ThreadDTO) {
        let users = dto.participants.map { MessengerUser(dto: $0) }
        var userById: [UUID: MessengerUser] = [:]
        users.forEach { userById[$0.id] = $0 }

        let msgs = dto.messages.map { m in
            MessageModel(dto: m, sender: userById[m.senderId] ?? users.first!)
        }
        self.init(id: dto.id, participants: users, messages: msgs)
    }
}

// MARK: - Small helpers

extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if s.count == 6 { s.append("FF") }
        guard s.count == 8, let v = UInt64(s, radix: 16) else { return nil }
        let r = Double((v & 0xFF00_0000) >> 24) / 255
        let g = Double((v & 0x00FF_0000) >> 16) / 255
        let b = Double((v & 0x0000_FF00) >> 8)  / 255
        let a = Double(v & 0x0000_00FF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
