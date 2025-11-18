//
//  MessengerUser.swift
//  LiteMessenger

import SwiftUI

struct MessengerUser: Identifiable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: String
    var status: String
    var bio: String
    var color: Color
    
    static let placeholder = MessengerUser(
        id: UUID(),
        name: "New User",
        email: "placeholder@example.com",
        role: "Contributor",
        status: "Available",
        bio: "Tell others about yourself.",
        color: .gray
    )
}
