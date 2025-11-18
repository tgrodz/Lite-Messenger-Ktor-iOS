//
//  SettingsView.swift
//  LiteMessenger

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MessengerViewModel
    @State private var draftUser: MessengerUser
    
    init(viewModel: MessengerViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        _draftUser = State(initialValue: viewModel.currentUser ?? .placeholder)
    }
    @State private var pushEnabled = true
    @State private var readReceipts = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Name", text: Binding(get: { draftUser.name }, set: { draftUser.name = $0 }))
                    TextField("Role", text: Binding(get: { draftUser.role }, set: { draftUser.role = $0 }))
                    TextField("Status", text: Binding(get: { draftUser.status }, set: { draftUser.status = $0 }))
                }
                
                Section("Preferences") {
                    Toggle("Push notifications", isOn: $pushEnabled)
                    Toggle("Read receipts", isOn: $readReceipts)
                    TextField("Bio", text: Binding(get: { draftUser.bio }, set: { draftUser.bio = $0 }), axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Files & Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showFilesSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateUser(with: draftUser)
                        viewModel.showFilesSheet = false
                    }
                }
            }
            .onAppear {
                draftUser = viewModel.currentUser ?? .placeholder
            }
        }
    }
}
