
//  MessageListView.swift
//  LiteMessenger

import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessengerViewModel
    @State private var draft = ""
    @FocusState private var inputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if let chat = viewModel.selectedChat, let current = viewModel.currentUser {
                ZStack {
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGray6)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(chat.messages) { message in
                                    MessageBubble(
                                        message: message,
                                        isCurrentUser: message.sender == current
                                    )
                                    .id(message.id)
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 12)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .contentShape(Rectangle())
                        .onTapGesture { inputFocused = false }
                        .onAppear {
                            if let lastID = chat.messages.last?.id {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                        .onChange(of: chat.messages.count) { _, _ in
                            if let lastID = chat.messages.last?.id {
                                withAnimation(.easeOut(duration: 0.22)) {
                                    proxy.scrollTo(lastID, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: viewModel.selectedChat?.id) { _, _ in
                            // when switching chats, jump to bottom
                            if let lastID = viewModel.selectedChat?.messages.last?.id {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(lastID, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Floating composer
                SafeAreaComposer(
                    draft: $draft,
                    sendAction: sendDraft,
                    inputFocused: _inputFocused
                )
            } else {
                EmptyState()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Keyboard toolbar “Done”
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { inputFocused = false }
            }
        }
    }
}

// MARK: - Pieces

private extension MessageListView {
    func sendDraft() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.send(message: trimmed)
        draft = ""
    }
    
    @ViewBuilder
    func EmptyState() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 42))
                .foregroundColor(.secondary)
            Text("Select a chat to get started")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Composer

fileprivate struct SafeAreaComposer: View {
    @Binding var draft: String
    let sendAction: () -> Void
    @FocusState var inputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0)
            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    if draft.isEmpty {
                        Text("Message")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                    }
                    TextField("", text: $draft, axis: .vertical)
                        .focused($inputFocused)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.send)
                        .onSubmit { sendAction() }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Button(action: sendAction) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(14)
                        .background(
                            Circle().fill(
                                LinearGradient(
                                    colors: [
                                        .orange,
                                        Color(red: 0.95, green: 0.40, blue: 0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                        .shadow(color: Color.orange.opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
}
