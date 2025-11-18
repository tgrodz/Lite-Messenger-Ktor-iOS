//
//  ProfileDetailView.swift
//  LiteMessenger

import SwiftUI

struct ProfileDetailView: View {
    @ObservedObject var viewModel: MessengerViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            LinearGradient(colors: [user.color.opacity(0.8), Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            VStack(spacing: 8) {
                                AvatarView(name: user.name, color: user.color)
                                    .frame(width: 72, height: 72)
                                Text(user.name)
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Text(user.email)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.headline)
                            ProfileRow(title: "Role", value: user.role, icon: "person.fill")
                            ProfileRow(title: "Status", value: user.status, icon: "waveform.path.ecg.rectangle")
                            ProfileRow(title: "Bio", value: user.bio, icon: "text.book.closed.fill")
                        }
                        .padding()
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        Button {
                            viewModel.logout()
                            viewModel.showProfileSheet = false
                        } label: {
                            Text("Sign out")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red, in: RoundedRectangle(cornerRadius: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Your Profile")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { viewModel.showProfileSheet = false }
                    }
                }
            }
        }
    }
}
