//  LoginView.swift
//  LiteMessenger

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: MessengerViewModel
    @FocusState private var focusedField: Field?
    
    private enum Field { case email, password }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Lite Messenger")
                        .font(.largeTitle.bold())
                    Text(viewModel.authMode == .login
                         ? "Sign in to continue the conversation"
                         : "Create an account to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if viewModel.authMode == .signup {
                    TextField("Full name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .focused($focusedField, equals: .email)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .focused($focusedField, equals: .password)
                }
                
                if let error = viewModel.loginError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    focusedField = nil
                    viewModel.submitAuth()
                }) {
                    HStack {
                        if viewModel.isAuthenticating {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: viewModel.authMode == .login
                                  ? "arrow.right.circle.fill"
                                  : "person.crop.circle.badge.plus")
                            Text(viewModel.authMode == .login ? "Sign in" : "Create account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                .disabled(viewModel.isAuthenticating)
                
                Button(action: { viewModel.toggleAuthMode() }) {
                    Text(viewModel.authMode == .login
                         ? "Need an account? Sign up"
                         : "Already have an account? Sign in")
                        .font(.footnote)
                        .foregroundColor(.indigo)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 30)
            )
            .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
