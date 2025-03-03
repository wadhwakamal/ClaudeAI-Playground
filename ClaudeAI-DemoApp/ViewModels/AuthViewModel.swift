import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    init(apiClient: APIClientProtocol = APIClient(),
         tokenManager: TokenManagerProtocol = TokenManager()) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
        self.isAuthenticated = tokenManager.isAuthenticated
    }
    
    func login(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let success = try await apiClient.login(email: email, password: password)
            isAuthenticated = success
            return success
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            return false
        } catch let error as AuthenticationError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = "An unexpected error occurred"
            return false
        }
    }
    
    func logout() async {
        isLoading = true
        
        // Updated to match the non-throwing logout method
        try? await apiClient.logout()
        
        isAuthenticated = false
        isLoading = false
    }
    
    func checkAuthentication() {
        isAuthenticated = tokenManager.isAuthenticated
    }
}
