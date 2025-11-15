//
//  Region.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

// https://pokeapi.co/api/v2/region
struct RegionIndexResponse: Codable {
    let results: [RegionIndexItem]
}

struct RegionIndexItem: Codable {
    let name: String
    let url: String
}

// https://pokeapi.co/api/v2/region/{id}/
struct RegionDetailResponse: Codable {
    let name: String
    let locations: [NamedAPIResource]

    var locationCount: Int {
        locations.count
    }
}

struct NamedAPIResource: Codable {
    let name: String
    let url: String
}

struct Region {
    let name: String
    let locationCount: Int
}

/// 用 list item + detail 組合出你要的 Region
extension Region {
    init(indexItem: RegionIndexItem, detail: RegionDetailResponse) {
        self.name = indexItem.name
        self.locationCount = detail.locationCount
    }
}
