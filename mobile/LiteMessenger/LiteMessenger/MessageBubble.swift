//
//  MessageBubble.swift
//  LiteMessenger

import SwiftUI

struct MessageBubble: View {
    let message: MessageModel
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                // Sender label – stronger, clearer
                if !isCurrentUser {
                    Text(message.sender.name)
                        .font(.footnote.weight(.semibold))          // was .caption2
                        .foregroundColor(.primary.opacity(0.8))      // was .secondary
                        .lineLimit(1)
                }
                
                // Bubble
                Text(message.text)
                    .font(.body)                                     // keep readable
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isCurrentUser
                                  // Orange → deep orange for outgoing
                                  ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.orange,
                                                Color(red: 0.95, green: 0.40, blue: 0.10)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                  // Soft white for incoming
                                  : AnyShapeStyle(Color.white))
                    )
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isCurrentUser ? Color.clear : Color.gray.opacity(0.08), lineWidth: 1)
                    )
                
                // Time
                Text(MessengerFormatter.timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}

