//
//  ProfileViewModel.swift
//  LiteMessenger

import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var draftUser: MessengerUser = .placeholder

    func load(using session: SessionViewModel) {
        if let u = session.currentUser { draftUser = u }
    }

    func save(using session: SessionViewModel) {
        session.repo.updateProfile(draftUser)
        // update session user reference
        if let _ = session.currentUser { session.signOut(); } // reset to rebind, or:
        // simpler: expose a method in SessionViewModel to set currentUser directly:
        // session.setCurrentUser(draftUser)
    }
}
