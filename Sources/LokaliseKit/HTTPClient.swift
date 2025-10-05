//
//  HTTPClient.swift
//

import Foundation
import Combine

/// Defines errors for networking
enum HTTPError: LocalizedError {
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from server"
        case .statusCode(let code): return "Request failed with status code \(code)"
        case .decodingError(let error): return "Decoding failed: \(error.localizedDescription)"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

/// Protocol to abstract HTTPClient for testability
protocol HTTPClientProtocol {
    func request<T: Decodable>(_ endpoint: URLRequest, decodeTo type: T.Type) -> AnyPublisher<T, HTTPError>
}

final class HTTPClient: HTTPClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T>(_ endpoint: URLRequest, decodeTo type: T.Type) -> AnyPublisher<T, HTTPError> where T : Decodable {
        session.dataTaskPublisher(for: endpoint)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw HTTPError.invalidResponse
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw HTTPError.statusCode(httpResponse.statusCode)
                }
                
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> HTTPError in
                switch error {
                case is Swift.DecodingError:
                    return .decodingError(error)
                case let httpError as HTTPError:
                    return httpError
                default:
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
}
