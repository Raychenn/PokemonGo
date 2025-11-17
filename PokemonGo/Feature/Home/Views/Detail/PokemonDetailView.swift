//
//  PokemonDetailView.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/16.
//

import SwiftUI
import Kingfisher

struct PokemonDetailView: View {
    
    let pokemon: PokemonSummary
    @State private var isFavorite: Bool
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    init(pokemon: PokemonSummary) {
        self.pokemon = pokemon
        self._isFavorite = State(initialValue: pokemon.isFavorite)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeAreaTop = geometry.safeAreaInsets.top
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        LinearGradient(
                            colors: [
                                Color(getTypeColor(for: pokemon.typeNames.first ?? "normal")),
                                Color(getTypeColor(for: pokemon.typeNames.first ?? "normal")).opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 300 + safeAreaTop)
                        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                        .padding(.top, -safeAreaTop)
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                        
                        VStack {
                            Spacer()
                                .frame(height: 100)
                            
                            if let imageURLString = pokemon.imageURLString,
                               let url = URL(string: imageURLString) {
                                KFImage(url)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 280, height: 280)
                                    .offset(y: 10)
                            }
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Name and Types
                        VStack(alignment: .center, spacing: 16) {
                            Text(pokemon.name.capitalized)
                                .font(.system(size: 36, weight: .bold))
                            
                            HStack(spacing: 12) {
                                ForEach(pokemon.typeNames, id: \.self) { typeName in
                                    Text(typeName.capitalized)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 8)
                                        .background(
                                            ZStack {
                                                Color(getTypeColor(for: typeName))
                                                    .opacity(0.3)
                                                    .blur(radius: 10)
                                            }
                                        )
                                        .cornerRadius(20)
                                        .shadow(color: Color(getTypeColor(for: typeName)).opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        
                        HStack(spacing: 16) {
                            // Weight Card
                            VStack(spacing: 8) {
                                Text(getWeight())
                                    .font(.system(size: 24, weight: .bold))
                                Text("Weight")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .cornerRadius(16)
                            
                            // Height Card
                            VStack(spacing: 8) {
                                Text(getHeight())
                                    .font(.system(size: 24, weight: .bold))
                                Text("Height")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Base Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Base Stats")
                                .font(.system(size: 28, weight: .bold))
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(pokemon.stats, id: \.name) { stat in
                                    StatRow(
                                        name: stat.name.uppercased(),
                                        value: stat.baseStat,
                                        color: getStatColor(for: stat.name)
                                    )
                                }
                            }
                            .padding(20)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .ignoresSafeArea(edges: .top)
            .toolbar {
                // Custom back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.backward.circle")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                
                // Title in center
                ToolbarItem(placement: .principal) {
                    Text("#\(String(format: "%03d", pokemon.id))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Favorite button in top right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isFavorite.toggle()
                        }
                        _ = UserDefaultManager.shared.toggleFavorite(pokemonId: pokemon.id)
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isFavorite ? .red : .white)
                            .symbolEffect(.bounce, value: isFavorite)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(
                // Custom navigation bar background
                GeometryReader { geo in
                    if scrollOffset < -50 {
                        Color(getTypeColor(for: pokemon.typeNames.first ?? "normal"))
                            .opacity(0.95)
                            .frame(height: geo.safeAreaInsets.top + 44)
                            .ignoresSafeArea(edges: .top)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.25), value: scrollOffset < -50)
                    }
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func getWeight() -> String {
        return String(format: "%.1f KG", pokemon.weight)
    }
    
    private func getHeight() -> String {
        return String(format: "%.1f M", pokemon.height)
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
    
    private func getStatColor(for statName: String) -> Color {
        switch statName.lowercased() {
        case "hp": return Color(red: 1.0, green: 0.34, blue: 0.34)
        case "attack": return Color(red: 0.96, green: 0.60, blue: 0.31)
        case "defense": return Color(red: 0.25, green: 0.59, blue: 0.95)
        case "special-attack": return Color(red: 0.40, green: 0.71, blue: 0.98)
        case "special-defense": return Color(red: 0.60, green: 0.85, blue: 0.85)
        case "speed": return Color(red: 0.98, green: 0.84, blue: 0.25)
        default: return .gray
        }
    }
}

// MARK: - StatRow View

struct StatRow: View {
    let name: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(name.prefix(3))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 255.0)
                }
            }
            .frame(height: 8)
            
            Text("\(value)/255")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 60, alignment: .trailing)
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25
    var corners: UIRectCorner = [.bottomLeft, .bottomRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - ScrollOffsetPreferenceKey

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationView {
        PokemonDetailView(
            pokemon: PokemonSummary(
                id: 3,
                name: "venusaur",
                weight: 60,
                height: 2.0,
                typeNames: ["grass", "poison"],
                imageURLString: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png",
                stats: [
                    PokemonSummary.StatSummary(name: "hp", baseStat: 80),
                    PokemonSummary.StatSummary(name: "attack", baseStat: 82),
                    PokemonSummary.StatSummary(name: "defense", baseStat: 83),
                    PokemonSummary.StatSummary(name: "speed", baseStat: 80)
                ],
                isFavorite: false
            )
        )
    }
}
