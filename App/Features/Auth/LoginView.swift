//
//  LoginView.swift
//  App
//
//  Created by Saf on 12/1/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Header
            VStack(spacing: 24) {
                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Welcome to Butterfly")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Sign in to continue to your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            
            // Sign in with Apple Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    // Handle via coordinator to get presentation context
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .overlay(
                SignInWithAppleButtonRepresentable(viewModel: viewModel)
                    .frame(height: 50)
                    .opacity(0.01)
            )
        }
        .onAppear {
            viewModel.checkExistingCredentials()
        }
        .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // TODO: Navigate to main app
                print("✅ User authenticated - navigate to main app")
            }
        }
    }
}

// MARK: - Button Representable with Coordinator

struct SignInWithAppleButtonRepresentable: UIViewRepresentable {
    let viewModel: LoginViewModel
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.handlePress), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerPresentationContextProviding {
        let viewModel: LoginViewModel
        
        init(viewModel: LoginViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func handlePress() {
            let controller = viewModel.handleSignInWithApple()
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                fatalError("No window found")
            }
            return window
        }
    }
}

#Preview {
    LoginView()
}
