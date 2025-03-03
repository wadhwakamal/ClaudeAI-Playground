import Foundation
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchUser(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await apiClient.fetchUser(id: id)
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        
        isLoading = false
    }
    
    func updateUser(_ updatedUser: User) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            user = try await apiClient.updateUser(updatedUser)
            return true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = "An unexpected error occurred."
            return false
        }
    }
}
