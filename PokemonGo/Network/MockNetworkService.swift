//
//  MockNetworkService.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

/// Mock network service for testing purposes
final class MockNetworkService: NetworkServiceProtocol {
    
    var mockData: Data?
    var mockError: Error?
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw APIError.unknown
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

