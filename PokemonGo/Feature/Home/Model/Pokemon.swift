//
//  Pokemon.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

// MARK: - List Response (GET https://pokeapi.co/api/v2/pokemon?limit=20&offset=0)

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable {
    let name: String
    let url: String
    
    /// Extract ID from URL (e.g., "https://pokeapi.co/api/v2/pokemon/1/" -> 1)
    var id: Int? {
        guard let urlComponents = URLComponents(string: url) else { return nil }
        let pathComponents = urlComponents.path.split(separator: "/")
        guard let lastComponent = pathComponents.last else { return nil }
        return Int(lastComponent)
    }
}

// MARK: - Detail Response (GET https://pokeapi.co/api/v2/pokemon/{id}/)

struct Pokemon: Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let sprites: Sprites
    let stats: [PokemonStat]
    
    var imageURLString: String? {
        sprites.other?.officialArtwork.frontDefault ?? sprites.frontDefault
    }
}

struct PokemonType: Codable {
    let type: TypeInfo
}

struct TypeInfo: Codable {
    let name: String
}

struct PokemonStat: Codable {
    let baseStat: Int
    let effort: Int
    let stat: StatInfo
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort
        case stat
    }
}

struct StatInfo: Codable {
    let name: String
    let url: String
}

struct Sprites: Codable {
    let frontDefault: String?
    let other: OtherSprites?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case other
    }
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// MARK: - Summary Model (for UI/ViewModel)

struct PokemonSummary {
    let id: Int
    let name: String
    let typeNames: [String]
    let imageURLString: String?
    let stats: [StatSummary]
    var isFavorite: Bool 
    
    struct StatSummary {
        let name: String
        let baseStat: Int
    }
}

extension PokemonSummary {
    init(from pokemon: Pokemon) {
        self.id = pokemon.id
        self.name = pokemon.name
        self.typeNames = pokemon.types.map { $0.type.name }
        self.imageURLString = pokemon.imageURLString
        self.stats = pokemon.stats.map { StatSummary(name: $0.stat.name, baseStat: $0.baseStat) }
        self.isFavorite = UserDefaultManager.shared.isFavorite(pokemonId: pokemon.id)
    }
}

