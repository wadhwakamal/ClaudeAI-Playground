import Foundation
import SwiftData

/// API client for making network requests
protocol APIClientProtocol {
    func fetchUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func fetchUsers() async throws -> [User]
    func login(email: String, password: String) async throws -> Bool
    func logout() async throws
    // Add more methods as needed
}

class APIClient: APIClientProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenManager: TokenManagerProtocol
    private let baseURL: URL
    
    init(networkService: NetworkServiceProtocol = NetworkService(), 
         tokenManager: TokenManagerProtocol = TokenManager(),
         baseURL: URL = URL(string: "https://api.example.com")!) {
        self.networkService = networkService
        self.tokenManager = tokenManager
        self.baseURL = baseURL
    }
    
    func fetchUser(id: String) async throws -> User {
        let endpoint = try await authenticatedEndpoint(
            APIEndpoints.GetUser(baseURL: baseURL, id: id)
        )
        return try await networkService.request(endpoint)
    }
    
    func updateUser(_ user: User) async throws -> User {
        let endpoint = try await authenticatedEndpoint(
            APIEndpoints.UpdateUser(baseURL: baseURL, user: user)
        )
        return try await networkService.request(endpoint)
    }
    
    func fetchUsers() async throws -> [User] {
        let endpoint = try await authenticatedEndpoint(
            APIEndpoints.GetUsers(baseURL: baseURL)
        )
        return try await networkService.request(endpoint)
    }
    
    func login(email: String, password: String) async throws -> Bool {
        let endpoint = AuthEndpoints.login(baseURL: baseURL, email: email, password: password)
        let authResponse: AuthResponse = try await networkService.request(endpoint)
        
        tokenManager.setTokens(accessToken: authResponse.accessToken, refreshToken: authResponse.refreshToken)
        return true
    }
    
    func logout() async {
        // Removed throws since we're not actually throwing any errors
        tokenManager.clearTokens()
    }
    
    // MARK: - Private Methods
    
    /// Adds authentication header to the endpoint
    private func authenticatedEndpoint<T: APIEndpoint>(_ endpoint: T) async throws -> AuthenticatedEndpoint<T> {
        guard tokenManager.isAuthenticated else {
            throw NetworkError.unauthorized
        }
        
        guard let accessToken = tokenManager.accessToken else {
            throw NetworkError.unauthorized
        }
        
        // If token is expired, refresh it (this would require token expiry check)
        // For simplicity, we're not implementing token expiry checking here
        // but in a real app, you would check if the token is about to expire and refresh it
        
        return AuthenticatedEndpoint(endpoint: endpoint, accessToken: accessToken)
    }
}

// Wrapper to add authentication to an endpoint
struct AuthenticatedEndpoint<Base: APIEndpoint>: APIEndpoint {
    private let endpoint: Base
    private let accessToken: String
    
    init(endpoint: Base, accessToken: String) {
        self.endpoint = endpoint
        self.accessToken = accessToken
    }
    
    var baseURL: URL { return endpoint.baseURL }
    var path: String { return endpoint.path }
    var method: HTTPMethod { return endpoint.method }
    var queryParameters: [String: String]? { return endpoint.queryParameters }
    var body: Data? { return endpoint.body }
    var timeoutInterval: TimeInterval { return endpoint.timeoutInterval }
    var cachePolicy: URLRequest.CachePolicy { return endpoint.cachePolicy }
    
    var headers: [String: String]? {
        var headers = endpoint.headers ?? [:]
        headers["Authorization"] = "Bearer \(accessToken)"
        return headers
    }
}

// MARK: - API Endpoints

enum APIEndpoints {
    // Using PascalCase for struct names to follow Swift conventions
    struct GetUser: APIEndpoint {
        let baseURL: URL
        let id: String
        
        var path: String { return "/users/\(id)" }
        var method: HTTPMethod { return .get }
        var headers: [String: String]? { 
            return ["Accept": "application/json"] 
        }
    }
    
    struct GetUsers: APIEndpoint {
        let baseURL: URL
        
        var path: String { return "/users" }
        var method: HTTPMethod { return .get }
        var headers: [String: String]? { 
            return ["Accept": "application/json"] 
        }
    }
    
    struct UpdateUser: APIEndpoint {
        let baseURL: URL
        let user: User
        
        var path: String { return "/users/\(user.id.uuidString)" }
        var method: HTTPMethod { return .put }
        var headers: [String: String]? { 
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ] 
        }
        var body: Data? {
            return try? JSONEncoder().encode(user)
        }
    }
}
