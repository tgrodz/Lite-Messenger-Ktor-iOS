//
//  ChatThread.swift
//  LiteMessenger

import SwiftUI

struct ChatThread: Identifiable, Equatable, Hashable {
    let id: UUID
    var participants: [MessengerUser]
    var messages: [MessageModel]
    
    static func == (lhs: ChatThread, rhs: ChatThread) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func contactName(excluding current: MessengerUser?) -> String {
        if let current, let other = participants.first(where: { $0.id != current.id }) {
            return other.name
        }
        return participants.first?.name ?? "Unknown"
    }
    
    func contactColor(excluding current: MessengerUser?) -> Color {
        if let current, let other = participants.first(where: { $0.id != current.id }) {
            return other.color
        }
        return participants.first?.color ?? .gray
    }
}
