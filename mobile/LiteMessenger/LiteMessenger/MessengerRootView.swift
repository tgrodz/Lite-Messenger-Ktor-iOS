//
//  MessengerRootView.swift
//  LiteMessenger

import SwiftUI

struct MessengerRootView: View {
    @ObservedObject var viewModel: MessengerViewModel
    
    var body: some View {
        Group {
            if viewModel.currentUser == nil {
                LoginView(viewModel: viewModel)
            } else {
                UserMessengerView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.currentUser != nil)
    }
}
