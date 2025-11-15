//
//  PokemonEndpoint.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

enum PokemonEndpoint: Endpoint {
    case list(limit: Int, offset: Int)
    case detail(id: Int)
    case types
    case regionList
    case regionDetail(id: Int)
    
    var baseURL: String {
        return "https://pokeapi.co/api/v2"
    }
    
    var path: String {
        switch self {
        case .list:
            return "/pokemon"
        case .detail(let id):
            return "/pokemon/\(id)"
        case .types:
            return "/type"
        case .regionList:
            return "/region"
        case .regionDetail(let id):
            return "/region/\(id)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .list(let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        default:
            return nil
        }
    }
}

