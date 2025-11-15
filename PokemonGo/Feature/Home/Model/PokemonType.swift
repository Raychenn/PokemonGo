//
//  Type.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

// https://pokeapi.co/api/v2/type
struct PokemonTypeListResponse: Codable {
    let results: [PokemonTypeItem]
    
    var typeNames: [String] {
        results.map { $0.name }
    }
}

struct PokemonTypeItem: Codable {
    let name: String
}
