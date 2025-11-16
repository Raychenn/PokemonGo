//
//  PokemonGoTests.swift
//  PokemonGoTests
//
//  Created by Boray Chen on 2025/11/14.
//

import Testing
@testable import PokemonGo

struct PokemonGoTests {

    @Test func testPokemonListItemIDExtraction() async throws {
        // Given
        let item = PokemonListItem(
            name: "bulbasaur",
            url: "https://pokeapi.co/api/v2/pokemon/1/"
        )
        
        // When
        let id = item.id
        
        // Then
        #expect(id == 1)
    }
    
    @Test func testPokemonSummaryInitialization() async throws {
        // Given
        let pokemon = Pokemon(
            id: 1,
            name: "bulbasaur",
            types: [
                PokemonType(type: TypeInfo(name: "grass")),
                PokemonType(type: TypeInfo(name: "poison"))
            ],
            sprites: Sprites(
                frontDefault: "https://example.com/sprite.png",
                other: nil
            ),
            stats: [
                PokemonStat(
                    baseStat: 45,
                    effort: 0,
                    stat: StatInfo(name: "hp", url: "https://pokeapi.co/api/v2/stat/1/")
                ),
                PokemonStat(
                    baseStat: 49,
                    effort: 0,
                    stat: StatInfo(name: "attack", url: "https://pokeapi.co/api/v2/stat/2/")
                )
            ]
        )
        
        // When
        let summary = PokemonSummary(from: pokemon)
        
        // Then
        #expect(summary.id == 1)
        #expect(summary.name == "bulbasaur")
        #expect(summary.typeNames == ["grass", "poison"])
        #expect(summary.imageURLString == "https://example.com/sprite.png")
        #expect(summary.stats.count == 2)
        #expect(summary.stats[0].name == "hp")
        #expect(summary.stats[0].baseStat == 45)
    }
    
    @Test func testMockNetworkService() async throws {
        // Given
        let mockService = MockNetworkService()
        let mockJSON = """
        {
            "count": 1328,
            "next": "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20",
            "previous": null,
            "results": [
                {
                    "name": "bulbasaur",
                    "url": "https://pokeapi.co/api/v2/pokemon/1/"
                }
            ]
        }
        """
        mockService.mockData = mockJSON.data(using: .utf8)
        
        let apiService = PokemonAPIService(networkService: mockService)
        
        // When
        let response: PokemonListResponse = try await apiService.fetchPokemonList(limit: 1, offset: 0)
        
        // Then
        #expect(response.count == 1328)
        #expect(response.results.count == 1)
        #expect(response.results.first?.name == "bulbasaur")
        #expect(response.results.first?.id == 1)
    }
    
    @Test func testHomeViewModelInitialization() async throws {
        // Given
        let mockService = MockNetworkService()
        let viewModel = HomeViewModel(apiService: PokemonAPIService(networkService: mockService))
        
        // Then
        #expect(viewModel.dataSoruce.featuredPokemons.isEmpty)
        #expect(viewModel.dataSoruce.pokemonTypes.isEmpty)
        #expect(viewModel.dataSoruce.regions.isEmpty)
        #expect(!viewModel.isLoading)
    }
    
    @Test func testHomeViewModelSections() async throws {
        // Given
        let viewModel = HomeViewModel()
        
        // Then
        #expect(viewModel.numberOfSections() == 3)
        #expect(HomeViewModel.Section.feature.title == "Featured Pokemon")
        #expect(HomeViewModel.Section.types.title == "Types")
        #expect(HomeViewModel.Section.regions.title == "Regions")
    }

}
