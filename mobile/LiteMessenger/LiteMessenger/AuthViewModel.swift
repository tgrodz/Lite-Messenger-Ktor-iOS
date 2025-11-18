//
//  AuthViewModel.swift
//  LiteMessenger

import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var isAuthenticating = false
    @Published var error: String?
    @Published var mode: Mode = .login

    enum Mode { case login, signup }

    @MainActor
    func submit(using session: SessionViewModel) {
        error = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            switch mode {
            case .login:
                guard !email.isEmpty, !password.isEmpty else {
                    error = "Enter both email and password."
                    return
                }
                try session.signIn(email: email, password: password)

            case .signup:
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                    error = "Name is required."
                    return
                }
                guard !email.isEmpty, !password.isEmpty else {
                    error = "Email and password are required."
                    return
                }
                try session.signUp(name: name, email: email, password: password)
            }
            // clear fields after success
            email = ""; password = ""; if mode == .signup { name = "" }
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }

    func toggle() {
        mode = (mode == .login ? .signup : .login)
        error = nil
    }
}
