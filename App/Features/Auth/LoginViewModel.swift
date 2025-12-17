//
//  LoginViewModel.swift
//  App
//
//  Created by Saf on 12/8/25.
//

import Foundation
import AuthenticationServices
import Security

class LoginViewModel: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var userIdentifier: String?
    @Published var fullName: PersonNameComponents?
    @Published var email: String?
    
    private let keychainService = "com.butterfly.health.app"
    private let keychainAccount = "userIdentifier"
    
    // MARK: - Public Methods
    
    /// Performs existing account setup flows for both Apple ID and password providers
    func performExistingAccountSetupFlows() -> ASAuthorizationController {
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        return authorizationController
    }
    
    /// Handles Sign in with Apple button press
    func handleSignInWithApple() -> ASAuthorizationController {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        return authorizationController
    }
    
    /// Check if user is already signed in
    func checkExistingCredentials() {
        if let savedUserIdentifier = loadUserFromKeychain() {
            self.userIdentifier = savedUserIdentifier
            
            // Check credential state
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: savedUserIdentifier) { [weak self] (credentialState, error) in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        self?.isAuthenticated = true
                    case .revoked, .notFound:
                        self?.isAuthenticated = false
                        self?.clearUserFromKeychain()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Keychain Methods
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        let data = Data(userIdentifier.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Unable to save userIdentifier to keychain. Status: \(status)")
        }
    }
    
    private func loadUserFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let userIdentifier = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return userIdentifier
    }
    
    private func clearUserFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // Save to keychain
            saveUserInKeychain(userIdentifier)
            
            // Update published properties
            DispatchQueue.main.async { [weak self] in
                self?.userIdentifier = userIdentifier
                self?.fullName = fullName
                self?.email = email
                self?.isAuthenticated = true
                self?.errorMessage = nil
                
                print("✅ Sign in successful")
                print("User ID: \(userIdentifier)")
                if let email = email {
                    print("Email: \(email)")
                }
                if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                    print("Name: \(givenName) \(familyName)")
                }
            }
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using existing iCloud Keychain credential
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            DispatchQueue.main.async { [weak self] in
                self?.isAuthenticated = true
                self?.errorMessage = nil
                print("✅ Password credential received")
                print("Username: \(username)")
            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            let authError = error as NSError
            if authError.code == ASAuthorizationError.canceled.rawValue {
                self?.errorMessage = "Sign in was canceled"
            } else {
                self?.errorMessage = error.localizedDescription
            }
            print("❌ Sign in failed: \(error.localizedDescription)")
        }
    }
}
