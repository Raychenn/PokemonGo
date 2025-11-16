//
//  SeeMorePokemonView.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/16.
//

import SwiftUI
import Kingfisher

struct SeeMorePokemonView: View {
    
    @StateObject private var viewModel = SeeMorePokemonViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.pokemons, id: \.id) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        PokemonListRow(pokemon: pokemon) {
                            viewModel.toggleFavorite(for: pokemon)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if viewModel.shouldLoadMore(currentItem: pokemon) {
                            viewModel.loadMorePokemons()
                        }
                    }
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // End of list message
                if !viewModel.hasMoreData && !viewModel.pokemons.isEmpty {
                    Text("No more Pokémon to load")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("All Pokémon")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadInitialData()
        }
    }
}

// MARK: - Pokemon List Row

struct PokemonListRow: View {
    let pokemon: PokemonSummary
    let onFavoriteTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Pokemon Image
            if let imageURLString = pokemon.imageURLString,
               let url = URL(string: imageURLString) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            }
            
            // Pokemon Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                Text("#\(pokemon.id)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(pokemon.typeNames, id: \.self) { typeName in
                        Text(typeName.capitalized)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(getTypeColor(for: typeName)))
                            .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavoriteTap) {
                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(pokemon.isFavorite ? .red : .gray)
                    .symbolEffect(.bounce, value: pokemon.isFavorite)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func getTypeColor(for type: String) -> UIColor {
        switch type.lowercased() {
        case "grass": return UIColor(red: 0.48, green: 0.78, blue: 0.48, alpha: 1.0)
        case "poison": return UIColor(red: 0.64, green: 0.44, blue: 0.68, alpha: 1.0)
        case "fire": return UIColor(red: 0.93, green: 0.51, blue: 0.29, alpha: 1.0)
        case "water": return UIColor(red: 0.39, green: 0.56, blue: 0.93, alpha: 1.0)
        case "electric": return UIColor(red: 0.98, green: 0.84, blue: 0.25, alpha: 1.0)
        case "normal": return UIColor(red: 0.66, green: 0.66, blue: 0.47, alpha: 1.0)
        case "fighting": return UIColor(red: 0.75, green: 0.19, blue: 0.15, alpha: 1.0)
        case "flying": return UIColor(red: 0.66, green: 0.56, blue: 0.95, alpha: 1.0)
        case "ground": return UIColor(red: 0.89, green: 0.75, blue: 0.42, alpha: 1.0)
        case "rock": return UIColor(red: 0.72, green: 0.63, blue: 0.42, alpha: 1.0)
        case "bug": return UIColor(red: 0.66, green: 0.73, blue: 0.13, alpha: 1.0)
        case "ghost": return UIColor(red: 0.44, green: 0.35, blue: 0.60, alpha: 1.0)
        case "steel": return UIColor(red: 0.72, green: 0.72, blue: 0.82, alpha: 1.0)
        case "psychic": return UIColor(red: 0.98, green: 0.33, blue: 0.45, alpha: 1.0)
        case "ice": return UIColor(red: 0.60, green: 0.85, blue: 0.85, alpha: 1.0)
        case "dragon": return UIColor(red: 0.44, green: 0.21, blue: 0.99, alpha: 1.0)
        case "dark": return UIColor(red: 0.44, green: 0.35, blue: 0.30, alpha: 1.0)
        case "fairy": return UIColor(red: 0.93, green: 0.60, blue: 0.67, alpha: 1.0)
        default: return .systemGray
        }
    }
}

#Preview {
    NavigationView {
        SeeMorePokemonView()
    }
}
