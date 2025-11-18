//
//  MessageModel.swift
//  LiteMessenger

import SwiftUI

struct MessageModel: Identifiable, Equatable {
    let id: UUID
    let sender: MessengerUser
    let text: String
    let timestamp: Date
    
    init(id: UUID = UUID(), sender: MessengerUser, text: String, timestamp: Date) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}
