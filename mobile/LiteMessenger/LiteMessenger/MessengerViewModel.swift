
//  MessengerViewModel.swift
//  LiteMessenger

import SwiftUI
import Foundation

final class MessengerViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var loginError: String?
    @Published var isAuthenticating = false
    @Published var authMode: AuthMode = .login
    
    @Published private(set) var currentUser: MessengerUser?
    @Published private(set) var chats: [ChatThread] = []
    @Published var selectedChat: ChatThread?
    
    @Published var searchQuery = ""
    @Published var searchResults: [MessengerUser] = []
    @Published var showFilesSheet = false
    @Published var showProfileSheet = false
    
    private let repository = MessengerRepository()
    
    enum AuthMode { case login, signup }
    
    func submitAuth() {
        loginError = nil
        switch authMode {
        case .login:
            guard !email.isEmpty, !password.isEmpty else {
                loginError = "Enter both email and password."
                return
            }
        case .signup:
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                loginError = "Name is required."
                return
            }
            guard !email.isEmpty, !password.isEmpty else {
                loginError = "Email and password are required."
                return
            }
        }
        
        isAuthenticating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            defer { self.isAuthenticating = false }
            switch self.authMode {
            case .login:
                guard let user = self.repository.authenticate(email: self.email, password: self.password) else {
                    self.loginError = "Invalid credentials"
                    return
                }
                self.completeAuth(for: user)
            case .signup:
                guard let user = self.repository.createAccount(name: self.name, email: self.email, password: self.password) else {
                    self.loginError = "Account already exists."
                    return
                }
                self.completeAuth(for: user)
            }
        }
    }
    
    func toggleAuthMode() {
        authMode = authMode == .login ? .signup : .login
        loginError = nil
    }
    
    private func completeAuth(for user: MessengerUser) {
        currentUser = user
        chats = repository.loadChats(for: user)
        selectedChat = chats.first
        email.removeAll()
        password.removeAll()
        if authMode == .signup { name.removeAll() }
    }
    
    func logout() {
        currentUser = nil
        chats.removeAll()
        selectedChat = nil
    }
    
    func select(chat: ChatThread) {
        selectedChat = chat
    }
    
    func send(message: String) {
        guard let currentUser, let selectedChat else { return }
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        chats = repository.send(message: trimmed, from: currentUser, in: selectedChat.id)
        self.selectedChat = chats.first(where: { $0.id == selectedChat.id })
    }
    
    func searchUsers() {
        guard let currentUser else {
            searchResults = []
            return
        }
        searchResults = repository.searchUsers(query: searchQuery, excluding: currentUser)
    }
    
    func startChat(with other: MessengerUser) {
        guard let currentUser else { return }
        selectedChat = repository.startChat(between: currentUser, and: other)
        chats = repository.loadChats(for: currentUser)
        searchQuery.removeAll()
        searchResults.removeAll()
    }
    
    func updateUser(with updated: MessengerUser) {
        guard currentUser != nil else { return }
        repository.updateProfile(updated)
        currentUser = updated
        chats = repository.loadChats(for: updated)
        if let selectedChat {
            self.selectedChat = chats.first(where: { $0.id == selectedChat.id })
        }
    }
}
