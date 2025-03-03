import Foundation

/// Main networking service that provides API request functionality
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Void
    func uploadData<T: Decodable>(_ data: Data, to endpoint: APIEndpoint, mimeType: String) async throws -> T
    func downloadData(from endpoint: APIEndpoint) async throws -> Data
}

/// Default implementation of NetworkServiceProtocol
class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, 
         decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        // Configure the decoder with common settings
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    /// Makes a network request and decodes the response to the specified type
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let (data, response) = try await performRequest(endpoint)
        return try decode(data: data, response: response)
    }
    
    /// Makes a network request without expecting a response body
    func request(_ endpoint: APIEndpoint) async throws -> Void {
        let (_, response) = try await performRequest(endpoint)
        try validateResponse(response, data: nil)
    }
    
    /// Uploads data to the specified endpoint
    func uploadData<T: Decodable>(_ data: Data, to endpoint: APIEndpoint, mimeType: String) async throws -> T {
        var request = endpoint.urlRequest()
        
        // Add upload-specific headers
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = mimeType
        headers["Content-Length"] = "\(data.count)"
        request.allHTTPHeaderFields = headers
        
        let (responseData, response) = try await session.upload(for: request, from: data)
        return try decode(data: responseData, response: response)
    }
    
    /// Downloads data from the specified endpoint
    func downloadData(from endpoint: APIEndpoint) async throws -> Data {
        let (data, response) = try await performRequest(endpoint)
        try validateResponse(response, data: data)
        return data
    }
    
    // MARK: - Private Methods
    
    private func performRequest(_ endpoint: APIEndpoint) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: endpoint.urlRequest())
        } catch let error as NSError {
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                throw NetworkError.noInternetConnection
            case NSURLErrorTimedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.requestFailed(error)
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        try validateResponse(response, data: data)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    private func validateResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
}
