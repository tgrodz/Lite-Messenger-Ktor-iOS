//
//  SessionViewModel.swift
//  LiteMessenger

import SwiftUI
import Combine

final class SessionViewModel: ObservableObject {
    @Published private(set) var currentUser: MessengerUser?
    private let repository: MessengerRepository

    init(repository: MessengerRepository = .init()) {
        self.repository = repository
    }

    // Expose repo to children in a controlled way
    var repo: MessengerRepository { repository }

    func signIn(email: String, password: String) throws {
        guard let user = repository.authenticate(email: email, password: password) else {
            throw AuthError.invalidCredentials
        }
        currentUser = user
    }

    func signUp(name: String, email: String, password: String) throws {
        guard let user = repository.createAccount(name: name, email: email, password: password) else {
            throw AuthError.accountExists
        }
        currentUser = user
    }

    func signOut() {
        currentUser = nil
    }

    enum AuthError: LocalizedError {
        case invalidCredentials, accountExists
        var errorDescription: String? {
            switch self {
            case .invalidCredentials: return "Invalid credentials"
            case .accountExists:      return "Account already exists."
            }
        }
    }
}
