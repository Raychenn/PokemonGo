//
//  HomeViewModel.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    // MARK: - Section Definition
    
    enum Section: Int, CaseIterable {
        case feature = 0
        case types
        case regions
        
        var title: String {
            switch self {
            case .feature:
                return "Featured Pokemon"
            case .types:
                return "Types"
            case .regions:
                return "Regions"
            }
        }
    }
    
    // MARK: - Properties
    
    enum Input {
        case favoritePokemonsUpdated(pokemonId: Int)
        case lifeCycele(ViewControllerLifeCycle)
    }
    
    class Output {
        @Published var isLoading = false
        @Published var errorMessage: String?
        let reloadData = PassthroughSubject<Void, Never>()
    }
    
    class DataSource {
        @Published var featuredPokemons: [PokemonSummary] = []
        @Published var pokemonTypes: [String] = []
        @Published var regions: [Region] = []
    }
    
    @Published private var isLoadingPokemons = false
    @Published private var isLoadingTypes = false
    @Published private var isLoadingRegions = false
    
    let state = Output()
    
    // MARK: - Private Properties
    
    private let apiService: PokemonAPIServiceProtocol
    private let dataSoruce = DataSource()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(apiService: PokemonAPIServiceProtocol = PokemonAPIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    func transform(_ input: AnyPublisher<Input, Never>) -> Output {
        input.sink { [weak self] input in
            switch input {
            case .lifeCycele(let lifeCycle):
                switch lifeCycle {
                case .viewIsAppearing:
                    self?.loadAllData()
                default:
                    break
                }
            case .favoritePokemonsUpdated(pokemonId: let id):
                // Toggle favorite state in FavoriteManager
                let newState = UserDefaultManager.shared.toggleFavorite(pokemonId: id)
                print("pokemon.isFavorite from newState: \(newState), id: \(id)")
                // Update the pokemon in dataSource
                if let index = self?.dataSoruce.featuredPokemons.firstIndex(where: { $0.id == id }) {
                    self?.dataSoruce.featuredPokemons[index].isFavorite = newState
                }
                
                // Reload to update UI
                self?.state.reloadData.send(())
            }
        }
        .store(in: &cancellables)
        return state
    }
    
    // MARK: - Private Methods
    
    /// Load all data for home page
    private func loadAllData() {
        loadFeaturedPokemons()
        loadPokemonTypes()
        loadRegions()
    }
    
    /// Load first 9 featured pokemons
    private func loadFeaturedPokemons() {
        isLoadingPokemons = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                dataSoruce.featuredPokemons = try await apiService.fetchPokemonSummaries(limit: 9, offset: 0).sorted(by: { $0.id < $1.id })
                isLoadingPokemons = false
                state.reloadData.send(())
            } catch {
                state.errorMessage = "Failed to load pokemons: \(error.localizedDescription)"
                isLoadingPokemons = false
            }
        }
    }
    
    /// Load all pokemon types
    private func loadPokemonTypes() {
        isLoadingTypes = true
        
        Task { @MainActor in
            do {
                let response = try await apiService.fetchTypes()
                dataSoruce.pokemonTypes = response.typeNames
                isLoadingTypes = false
                state.reloadData.send(())
            } catch {
                state.errorMessage = "Failed to load types: \(error.localizedDescription)"
                isLoadingTypes = false
            }
        }
    }
    
    /// Load first 6 regions for home page
    private func loadRegions() {
        isLoadingRegions = true
        
        Task { @MainActor in
            do {
                let allRegions = try await apiService.fetchRegions()
                // Only take first 6 regions for home page
                dataSoruce.regions = Array(allRegions.prefix(6))
                isLoadingRegions = false
                state.reloadData.send(())
            } catch {
                state.errorMessage = "Failed to load regions: \(error.localizedDescription)"
                isLoadingRegions = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    var isLoading: Bool {
        isLoadingPokemons || isLoadingTypes || isLoadingRegions
    }
    
    func numberOfSections() -> Int {
        return Section.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .feature:
            return dataSoruce.featuredPokemons.count
        case .types:
            return dataSoruce.pokemonTypes.count
        case .regions:
            return dataSoruce.regions.count
        }
    }
    
    func pokemon(at index: Int) -> PokemonSummary? {
        return dataSoruce.featuredPokemons[safe: index]
    }
    
    func type(at index: Int) -> String? {
        return dataSoruce.pokemonTypes[safe: index]
    }
    
    func region(at index: Int) -> Region? {
        return dataSoruce.regions[safe: index]
    }
}
