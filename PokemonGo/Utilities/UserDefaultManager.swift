//
//  FavoriteManager.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/16.
//

import Foundation

final class UserDefaultManager {
    
    // MARK: - Singleton
    
    static let shared = UserDefaultManager()
    
    private init() {}
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoritePokemonIds"
    
    // MARK: - Public Methods
    
    /// Get all favorite Pokemon IDs
    func getFavoritePokemonIds() -> Set<Int> {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
            return []
        }
        return ids
    }
    
    /// Check if a Pokemon is favorited
    func isFavorite(pokemonId: Int) -> Bool {
        return getFavoritePokemonIds().contains(pokemonId)
    }
    
    /// Toggle favorite status for a Pokemon
    @discardableResult
    func toggleFavorite(pokemonId: Int) -> Bool {
        var favorites = getFavoritePokemonIds()
        
        if favorites.contains(pokemonId) {
            favorites.remove(pokemonId)
        } else {
            favorites.insert(pokemonId)
        }
        
        saveFavorites(favorites)
        return favorites.contains(pokemonId)
    }
    
    /// Add a Pokemon to favorites
    func addFavorite(pokemonId: Int) {
        var favorites = getFavoritePokemonIds()
        favorites.insert(pokemonId)
        saveFavorites(favorites)
    }
    
    /// Remove a Pokemon from favorites
    func removeFavorite(pokemonId: Int) {
        var favorites = getFavoritePokemonIds()
        favorites.remove(pokemonId)
        saveFavorites(favorites)
    }
    
    /// Clear all favorites
    func clearAllFavorites() {
        userDefaults.removeObject(forKey: favoritesKey)
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites(_ favorites: Set<Int>) {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        userDefaults.set(data, forKey: favoritesKey)
    }
}

