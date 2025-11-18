//
//  HeaderView.swift
//  LiteMessenger

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: MessengerViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // Orange → deep orange → near-black gradient with rounded bottom
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange,
                            Color(red: 0.95, green: 0.40, blue: 0.10),
                            Color(red: 0.08, green: 0.08, blue: 0.10) // dark end
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 190)
                .ignoresSafeArea(edges: .top)

            // Content that adapts without breaking lines
            content
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Lite Messenger header"))
    }

    // MARK: - Pieces

    @ViewBuilder
    private var content: some View {
        // Try to keep a single clean row; if it doesn't fit, stack neatly
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 14) {
                titleBlock
                Spacer(minLength: 12)
                rightControls
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    titleBlock
                    Spacer()
                }
                HStack {
                    rightControls
                    Spacer()
                }
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Lite Messenger")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)   // prevent wrapping

            Text("Connected as \(viewModel.currentUser?.name ?? "—")")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
        .layoutPriority(1)
    }

    private var rightControls: some View {
        HStack(spacing: 10) {
            if let user = viewModel.currentUser {
                Button {
                    viewModel.showProfileSheet = true
                } label: {
                    HStack(spacing: 10) {
                        AvatarView(name: user.name, color: user.color)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)

                            Text(user.status)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .fixedSize(horizontal: true, vertical: false) // keep horizontal layout
            }

            Button {
                viewModel.showFilesSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill").imageScale(.medium)
                    Text("Files").font(.headline)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                .foregroundColor(.orange)
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }
}
