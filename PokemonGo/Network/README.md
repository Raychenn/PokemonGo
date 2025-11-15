# Pokemon API Layer

這個 API Layer 使用 Swift Concurrency（async/await）設計，具備以下特點：

## 特點

1. **可測試性**：使用 Protocol 設計，方便注入 Mock 進行單元測試
2. **易用性**：提供簡潔的 API 介面，隱藏複雜的網路請求細節
3. **複用性**：模組化設計，可以輕鬆擴展新的 API endpoint
4. **並發處理**：使用 TaskGroup 並發請求多個 Pokemon 詳細資料，提升效能

## 架構說明

```
Network/
├── APIError.swift              # 統一的錯誤處理
├── Endpoint.swift              # Endpoint protocol 定義
├── PokemonEndpoint.swift       # Pokemon API endpoints
├── NetworkService.swift        # 通用網路請求服務
├── PokemonAPIService.swift     # Pokemon 專用 API 服務
└── MockNetworkService.swift    # 測試用 Mock 服務
```

## 使用範例

### 1. 在 HomePage 取得前 9 個 Pokemon（推薦）

```swift
let apiService = PokemonAPIService()

Task {
    do {
        // 一次取得前 9 個 Pokemon 的完整資訊
        let summaries = try await apiService.fetchPokemonSummaries(limit: 9, offset: 0)
        
        for summary in summaries {
            print("ID: \(summary.id)")
            print("Name: \(summary.name)")
            print("Types: \(summary.typeNames.joined(separator: ", "))")
            print("Image: \(summary.imageURLString ?? "N/A")")
            print("Stats:")
            for stat in summary.stats {
                print("  - \(stat.name): \(stat.baseStat)")
            }
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### 2. 分步驟取得資料

```swift
let apiService = PokemonAPIService()

Task {
    do {
        // Step 1: 取得列表
        let listResponse = try await apiService.fetchPokemonList(limit: 9, offset: 0)
        
        // Step 2: 取得單一 Pokemon 詳細資料
        if let firstPokemonId = listResponse.results.first?.id {
            let detail = try await apiService.fetchPokemonDetail(id: firstPokemonId)
            print("Pokemon: \(detail.name)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### 3. 取得所有 Pokemon Types

```swift
let apiService = PokemonAPIService()

Task {
    do {
        let typesResponse = try await apiService.fetchTypes()
        let typeNames = typesResponse.typeNames
        print("Types: \(typeNames.joined(separator: ", "))")
    } catch {
        print("Error: \(error)")
    }
}
```

### 4. 取得所有 Regions

```swift
let apiService = PokemonAPIService()

Task {
    do {
        let regions = try await apiService.fetchRegions()
        for region in regions {
            print("\(region.name): \(region.locationCount) locations")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

## 在 ViewModel 中使用

```swift
import Combine

class HomeViewModel: ObservableObject {
    @Published var pokemons: [PokemonSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: PokemonAPIServiceProtocol
    
    init(apiService: PokemonAPIServiceProtocol = PokemonAPIService()) {
        self.apiService = apiService
    }
    
    func loadPokemons() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                pokemons = try await apiService.fetchPokemonSummaries(limit: 9, offset: 0)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
```

## 單元測試範例

```swift
import XCTest

class PokemonAPIServiceTests: XCTestCase {
    
    func testFetchPokemonList() async throws {
        // Arrange
        let mockService = MockNetworkService()
        let mockJSON = """
        {
            "count": 1,
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
        
        // Act
        let response = try await apiService.fetchPokemonList(limit: 1, offset: 0)
        
        // Assert
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results.first?.name, "bulbasaur")
        XCTAssertEqual(response.results.first?.id, 1)
    }
}
```

## API Reference

### PokemonAPIService

#### Methods

- `fetchPokemonList(limit:offset:)` - 取得 Pokemon 列表
- `fetchPokemonDetail(id:)` - 取得單一 Pokemon 詳細資料
- `fetchPokemonSummaries(limit:offset:)` - **推薦使用**：一次取得多個 Pokemon 的完整資訊
- `fetchTypes()` - 取得所有 Pokemon 類型
- `fetchRegionList()` - 取得 Region 列表
- `fetchRegionDetail(id:)` - 取得單一 Region 詳細資料
- `fetchRegions()` - 取得所有 Regions 及其 location 數量

### Models

- `PokemonListResponse` - Pokemon 列表回應
- `PokemonListItem` - Pokemon 列表項目（含 name 和 url）
- `Pokemon` - Pokemon 詳細資料
- `PokemonSummary` - 精簡的 Pokemon 資料（推薦給 UI 使用）
- `PokemonTypeListResponse` - Type 列表回應
- `RegionIndexResponse` - Region 列表回應
- `Region` - Region 資料（含 location 數量）

## 效能優化

API Service 使用 `withThrowingTaskGroup` 來並發請求多個 Pokemon 的詳細資料，大幅提升載入速度：

- 序列請求 9 個 Pokemon：約 9 秒（假設每個請求 1 秒）
- 並發請求 9 個 Pokemon：約 1-2 秒

## 錯誤處理

所有 API 方法都會拋出 `APIError`，包含以下類型：

- `.invalidURL` - URL 格式錯誤
- `.invalidResponse` - 伺服器回應格式錯誤
- `.httpError(statusCode:)` - HTTP 錯誤（如 404, 500）
- `.decodingError(Error)` - JSON 解析錯誤
- `.networkError(Error)` - 網路連線錯誤
- `.unknown` - 未知錯誤

## 參考資料

- [PokeAPI Documentation](https://pokeapi.co/docs/v2)
- [Pokemon List API](https://pokeapi.co/api/v2/pokemon?limit=20&offset=0)
- [Pokemon Detail API](https://pokeapi.co/api/v2/pokemon/1/)

