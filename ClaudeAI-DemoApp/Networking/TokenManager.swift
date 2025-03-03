import Foundation
import Security

/// Manages the authentication tokens for API requests
protocol TokenManagerProtocol {
    var accessToken: String? { get }
    var isAuthenticated: Bool { get }
    
    func setTokens(accessToken: String, refreshToken: String)
    func clearTokens()
    func refreshAccessToken() async throws -> String
}

class TokenManager: TokenManagerProtocol {
    private let keychain: KeychainServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL
    
    private enum Keys {
        static let accessToken = "com.claudeai-demoapp.accessToken"
        static let refreshToken = "com.claudeai-demoapp.refreshToken"
    }
    
    init(keychain: KeychainServiceProtocol = KeychainService(),
         networkService: NetworkServiceProtocol = NetworkService(),
         baseURL: URL = URL(string: "https://api.example.com")!) {
        self.keychain = keychain
        self.networkService = networkService
        self.baseURL = baseURL
    }
    
    var accessToken: String? {
        try? keychain.get(key: Keys.accessToken)
    }
    
    var refreshToken: String? {
        try? keychain.get(key: Keys.refreshToken)
    }
    
    var isAuthenticated: Bool {
        accessToken != nil
    }
    
    func setTokens(accessToken: String, refreshToken: String) {
        try? keychain.set(key: Keys.accessToken, value: accessToken)
        try? keychain.set(key: Keys.refreshToken, value: refreshToken)
    }
    
    func clearTokens() {
        try? keychain.delete(key: Keys.accessToken)
        try? keychain.delete(key: Keys.refreshToken)
    }
    
    func refreshAccessToken() async throws -> String {
        guard let refreshToken = self.refreshToken else {
            throw AuthenticationError.noRefreshToken
        }
        
        let endpoint = AuthEndpoints.refreshToken(baseURL: baseURL, refreshToken: refreshToken)
        let authResponse: AuthResponse = try await networkService.request(endpoint)
        
        setTokens(accessToken: authResponse.accessToken, refreshToken: authResponse.refreshToken)
        return authResponse.accessToken
    }
}

// MARK: - Authentication Endpoints

enum AuthEndpoints {
    struct login: APIEndpoint {
        let baseURL: URL
        let email: String
        let password: String
        
        var path: String { return "/auth/login" }
        var method: HTTPMethod { return .post }
        var headers: [String: String]? {
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
        var body: Data? {
            let credentials = ["email": email, "password": password]
            return try? JSONSerialization.data(withJSONObject: credentials)
        }
    }
    
    struct refreshToken: APIEndpoint {
        let baseURL: URL
        let refreshToken: String
        
        var path: String { return "/auth/refresh" }
        var method: HTTPMethod { return .post }
        var headers: [String: String]? {
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
        var body: Data? {
            let payload = ["refresh_token": refreshToken]
            return try? JSONSerialization.data(withJSONObject: payload)
        }
    }
}

// MARK: - Authentication Models

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

enum AuthenticationError: Error, LocalizedError {
    case noRefreshToken
    case refreshFailed
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available. Please log in again."
        case .refreshFailed:
            return "Failed to refresh authentication token. Please log in again."
        case .invalidCredentials:
            return "Invalid email or password."
        }
    }
}

// MARK: - Keychain Service

protocol KeychainServiceProtocol {
    func set(key: String, value: String) throws
    func get(key: String) throws -> String
    func delete(key: String) throws
}

class KeychainService: KeychainServiceProtocol {
    func set(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // First check if the item already exists
        var existingQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(existingQuery as CFDictionary, nil)
        
        if status == errSecSuccess {
            // Item exists, update it
            let updateQuery: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(existingQuery as CFDictionary, updateQuery as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: updateStatus)
            }
        } else if status == errSecItemNotFound {
            // Item doesn't exist, add it
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: addStatus)
            }
        } else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func get(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }
        
        guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        
        return value
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case encodingFailed
    case decodingFailed
    case unhandledError(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "The requested item could not be found in the keychain."
        case .duplicateItem:
            return "The item already exists in the keychain."
        case .encodingFailed:
            return "Failed to encode the string to data."
        case .decodingFailed:
            return "Failed to decode the data to string."
        case .unhandledError(let status):
            return "An unhandled error occurred with status: \(status)."
        }
    }
}
