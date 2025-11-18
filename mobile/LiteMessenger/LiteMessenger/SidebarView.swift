//  SidebarView.swift
//  LiteMessenger

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: MessengerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBar(text: $viewModel.searchQuery, placeholder: "Find a new user and add to chat")
                .onChange(of: viewModel.searchQuery) { _, _ in
                    viewModel.searchUsers()
                }
                .padding(.top, 12)
            
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(viewModel.searchResults) { user in
                        Button {
                            viewModel.startChat(with: user)
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(name: user.name, color: user.color)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name).fontWeight(.semibold)
                                    Text(user.role).font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill").foregroundColor(.indigo)
                            }
                            .padding()
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Text("Chats")
                .font(.headline)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.chats) { chat in
                        ChatRow(
                            chat: chat,
                            isSelected: chat.id == viewModel.selectedChat?.id,
                            currentUser: viewModel.currentUser,
                            lastMessageText: chat.messages.last?.text ?? ""
                        ) {
                            viewModel.select(chat: chat)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 16)
    }
}
