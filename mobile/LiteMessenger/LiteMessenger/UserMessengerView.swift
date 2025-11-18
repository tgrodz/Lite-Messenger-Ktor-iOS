//  UserMessengerView.swift
//  LiteMessenger

import SwiftUI

struct UserMessengerView: View {
    @ObservedObject var viewModel: MessengerViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(viewModel: viewModel)
                
                if sizeClass == .compact {
                    compactLayout
                } else {
                    desktopLayout
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $viewModel.showFilesSheet) {
            SettingsView(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.showProfileSheet) {
            ProfileDetailView(viewModel: viewModel)
                .presentationDetents([.large])
        }
    }
    
    private var desktopLayout: some View {
        HStack(spacing: 0) {
            SidebarView(viewModel: viewModel)
                .frame(width: 300)
                .background(Color(.systemGroupedBackground))
            Divider()
            MessageListView(viewModel: viewModel)
        }
    }
    
    private var compactLayout: some View {
        NavigationStack {
            SidebarView(viewModel: viewModel)
                .navigationDestination(item: $viewModel.selectedChat) { _ in
                    MessageListView(viewModel: viewModel)
                }
        }
    }
}
