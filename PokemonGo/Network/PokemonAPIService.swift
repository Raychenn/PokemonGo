//
//  PokemonAPIService.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

/// Protocol for Pokemon API service to enable testing with mock implementations
protocol PokemonAPIServiceProtocol {
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonSummaries(limit: Int, offset: Int) async throws -> [PokemonSummary]
    func fetchTypes() async throws -> PokemonTypeListResponse
    func fetchRegions() async throws -> [Region]
    func fetchRegionList() async throws -> RegionIndexResponse
    func fetchRegionDetail(id: Int) async throws -> RegionDetailResponse
}

final class PokemonAPIService: PokemonAPIServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Pokemon APIs
    
    /// Fetch pokemon list with pagination
    /// - Parameters:
    ///   - limit: Number of pokemon to fetch (default: 20)
    ///   - offset: Starting position (default: 0)
    /// - Returns: PokemonListResponse containing list of pokemon
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        return try await networkService.request(PokemonEndpoint.list(limit: limit, offset: offset))
    }
    
    /// Fetch detailed information for a specific pokemon
    /// - Parameter id: Pokemon ID
    /// - Returns: Pokemon detail
    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        return try await networkService.request(PokemonEndpoint.detail(id: id))
    }
    
    /// Fetch pokemon summaries (list + details combined)
    /// This is the main method for HomePage to fetch first 9 pokemon
    /// - Parameters:
    ///   - limit: Number of pokemon to fetch (default: 9)
    ///   - offset: Starting position (default: 0)
    /// - Returns: Array of PokemonSummary
    func fetchPokemonSummaries(limit: Int = 9, offset: Int = 0) async throws -> [PokemonSummary] {
        // Step 1: Fetch pokemon list
        let listResponse = try await fetchPokemonList(limit: limit, offset: offset)
        
        // Step 2: Fetch details for each pokemon concurrently
        let summaries = try await withThrowingTaskGroup(of: PokemonSummary?.self) { group in
            for item in listResponse.results {
                guard let id = item.id else { continue }
                
                group.addTask {
                    do {
                        let detail = try await self.fetchPokemonDetail(id: id)
                        return PokemonSummary(from: detail)
                    } catch {
                        // Log error but don't fail entire operation
                        print("Failed to fetch pokemon \(id): \(error)")
                        return nil
                    }
                }
            }
            
            var results: [PokemonSummary] = []
            for try await summary in group {
                if let summary = summary {
                    results.append(summary)
                }
            }
            return results
        }
        
        return summaries
    }
    
    // MARK: - Type APIs
    
    /// Fetch all pokemon types
    /// - Returns: PokemonTypeListResponse containing all types
    func fetchTypes() async throws -> PokemonTypeListResponse {
        return try await networkService.request(PokemonEndpoint.types)
    }
    
    // MARK: - Region APIs
    
    /// Fetch region list
    /// - Returns: RegionIndexResponse containing list of regions
    func fetchRegionList() async throws -> RegionIndexResponse {
        return try await networkService.request(PokemonEndpoint.regionList)
    }
    
    /// Fetch detailed information for a specific region
    /// - Parameter id: Region ID
    /// - Returns: RegionDetailResponse
    func fetchRegionDetail(id: Int) async throws -> RegionDetailResponse {
        return try await networkService.request(PokemonEndpoint.regionDetail(id: id))
    }
    
    /// Fetch all regions with location counts
    /// - Returns: Array of Region with location counts
    func fetchRegions() async throws -> [Region] {
        // Step 1: Fetch region list
        let listResponse = try await fetchRegionList()
        
        // Step 2: Fetch details for each region concurrently
        let regions = try await withThrowingTaskGroup(of: Region?.self) { group in
            for (index, item) in listResponse.results.enumerated() {
                let regionId = index + 1 // Region IDs start from 1
                
                group.addTask {
                    do {
                        let detail = try await self.fetchRegionDetail(id: regionId)
                        return Region(indexItem: item, detail: detail)
                    } catch {
                        print("Failed to fetch region \(regionId): \(error)")
                        return nil
                    }
                }
            }
            
            var results: [Region] = []
            for try await region in group {
                if let region = region {
                    results.append(region)
                }
            }
            return results
        }
        
        return regions
    }
}

