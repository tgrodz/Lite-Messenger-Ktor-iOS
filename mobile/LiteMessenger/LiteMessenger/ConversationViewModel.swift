//
//  ConversationViewModel.swift
//  LiteMessenger

import SwiftUI

final class ConversationViewModel: ObservableObject {
    @Published var draft = ""
    @Published var thread: ChatThread?

    func bind(to chat: ChatThread?) {
        thread = chat
    }

    func send(using session: SessionViewModel) {
        guard
            let me = session.currentUser,
            let thread = thread
        else { return }

        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        _ = session.repo.send(message: trimmed, from: me, in: thread.id)
        // reload thread from repo
        let refreshed = session.repo.loadChats(for: me).first { $0.id == thread.id }
        self.thread = refreshed
        draft = ""
    }
}
