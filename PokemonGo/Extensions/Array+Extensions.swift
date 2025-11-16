//
//  Array+Extensions.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
