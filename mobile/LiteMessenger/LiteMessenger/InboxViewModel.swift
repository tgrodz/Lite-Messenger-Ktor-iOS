//
//  InboxViewModel.swift
//  LiteMessenger

import SwiftUI

/// Drives the inbox (chat list, search, selection) for the current synchronous repository.
final class InboxViewModel: ObservableObject {
    @Published private(set) var chats: [ChatThread] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [MessengerUser] = []
    @Published var selectedChat: ChatThread?

    private let repository: MessengerRepository

    init(repository: MessengerRepository = MessengerRepository()) {
        self.repository = repository
    }

    // MARK: - Loading

    /// Load all chats for the given user and select the most recent one.
    func load(for user: MessengerUser) {
        let loaded = repository.loadChats(for: user)
        DispatchQueue.main.async {
            self.chats = loaded
            self.selectedChat = loaded.first
        }
    }

    /// Refresh chats while keeping current selection if possible.
    func refresh(for user: MessengerUser) {
        let keepId = selectedChat?.id
        let loaded = repository.loadChats(for: user)
        DispatchQueue.main.async {
            self.chats = loaded
            if let keepId, let refreshed = loaded.first(where: { $0.id == keepId }) {
                self.selectedChat = refreshed
            } else {
                self.selectedChat = loaded.first
            }
        }
    }

    // MARK: - Selection

    func select(_ chat: ChatThread) {
        selectedChat = chat
    }

    // MARK: - Search / Start chat

    /// Update `searchResults` based on `searchQuery` for the given user.
    func runSearch(for currentUser: MessengerUser) {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            searchResults = []
            return
        }
        searchResults = repository.searchUsers(query: q, excluding: currentUser)
    }

    /// Start a chat with `other` (or focus existing), then refresh inbox.
    func startChat(with other: MessengerUser, currentUser: MessengerUser) {
        let thread = repository.startChat(between: currentUser, and: other)
        let loaded = repository.loadChats(for: currentUser)
        self.chats = loaded
        self.selectedChat = loaded.first(where: { $0.id == thread.id }) ?? thread
        self.searchQuery = ""
        self.searchResults = []
    }

    // MARK: - Sending (optional helper if you want to send via InboxVM)

    /// Send a message in the currently selected chat and refresh state.
    func send(_ text: String, from currentUser: MessengerUser) {
        guard let selectedChat else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let loaded = repository.send(message: trimmed, from: currentUser, in: selectedChat.id)
        self.chats = loaded
        self.selectedChat = loaded.first(where: { $0.id == selectedChat.id })
    }
}
