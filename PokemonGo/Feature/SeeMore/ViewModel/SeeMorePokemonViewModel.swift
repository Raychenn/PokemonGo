//
//  SeeMorePokemonViewModel.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/16.
//

import Foundation
import Combine

@MainActor
class SeeMorePokemonViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var pokemons: [PokemonSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreData = true
    
    // MARK: - Private Properties
    
    private let apiService: PokemonAPIServiceProtocol
    private var currentOffset = 0
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(apiService: PokemonAPIServiceProtocol = PokemonAPIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() {
        guard pokemons.isEmpty else { return }
        currentOffset = 0
        hasMoreData = true
        loadMorePokemons()
    }
    
    func loadMorePokemons() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newPokemons = try await apiService.fetchPokemonSummaries(
                    limit: pageSize,
                    offset: currentOffset
                )
                
                if newPokemons.isEmpty {
                    hasMoreData = false
                } else {
                    let updatedPokemons = newPokemons.map { pokemon in
                        var updatedPokemon = pokemon
                        updatedPokemon.isFavorite = UserDefaultManager.shared.isFavorite(pokemonId: pokemon.id)
                        return updatedPokemon
                    }
                    
                    pokemons.append(contentsOf: updatedPokemons)
                    currentOffset += pageSize
                    
                    if newPokemons.count < pageSize {
                        hasMoreData = false
                    }
                }
                
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func toggleFavorite(for pokemon: PokemonSummary) {
        let newState = UserDefaultManager.shared.toggleFavorite(pokemonId: pokemon.id)
        
        if let index = pokemons.firstIndex(where: { $0.id == pokemon.id }) {
            pokemons[index].isFavorite = newState
        }
    }
    
    func shouldLoadMore(currentItem: PokemonSummary) -> Bool {
        guard let lastItem = pokemons.last else { return false }
        return currentItem.id == lastItem.id && hasMoreData && !isLoading
    }
}

