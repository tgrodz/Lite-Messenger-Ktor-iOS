//
//  ChatRow.swift
//  LiteMessenger

import SwiftUI

struct ChatRow: View {
    let chat: ChatThread
    let isSelected: Bool
    let currentUser: MessengerUser?
    let lastMessageText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AvatarView(
                    name: chat.contactName(excluding: currentUser),
                    color: chat.contactColor(excluding: currentUser)
                )
                .frame(width: 48, height: 48) // a bit larger
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(chat.contactName(excluding: currentUser))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(chat.messages.last.map { MessengerFormatter.relativeDateString(from: $0.timestamp) } ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(lastMessageText.isEmpty ? "No messages yet" : lastMessageText)
                        .font(.subheadline) // slightly larger than caption
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.indigo.opacity(0.12) : Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}
