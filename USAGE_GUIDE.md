# Pokemon Go App - 使用指南

## 專案概述

這是一個使用 **Swift Concurrency (async/await)** 和 **MVVM 架構**的 Pokemon Go iOS 應用程式，整合了 [PokeAPI](https://pokeapi.co/) 來顯示 Pokemon 資料。

## 架構設計

```
PokemonGo/
├── Feature/
│   └── Home/
│       ├── Model/
│       │   ├── Pokemon.swift          # Pokemon 相關 Models
│       │   ├── PokemonType.swift      # Type 相關 Models
│       │   └── Region.swift           # Region 相關 Models
│       └── ViewModel/
│           └── HomeViewModel.swift    # Home 頁面 ViewModel
├── Network/
│   ├── APIError.swift                 # API 錯誤定義
│   ├── Endpoint.swift                 # Endpoint Protocol
│   ├── PokemonEndpoint.swift          # Pokemon API Endpoints
│   ├── NetworkService.swift           # 通用網路服務
│   ├── PokemonAPIService.swift        # Pokemon API 服務
│   ├── MockNetworkService.swift       # 測試用 Mock 服務
│   └── README.md                      # API Layer 詳細說明
└── HomeViewController.swift           # Home 頁面 View Controller
```

## 主要功能

### 1. Model 設計

#### Pokemon Models

從 [`https://pokeapi.co/api/v2/pokemon?limit=9&offset=0`](https://pokeapi.co/api/v2/pokemon?limit=9&offset=0) 取得資料：

```swift
// 列表回應
struct PokemonListResponse: Codable {
    let count: Int
    let results: [PokemonListItem]
}

// 列表項目（含 ID 提取）
struct PokemonListItem: Codable {
    let name: String
    let url: String
    var id: Int? // 從 URL 自動提取
}

// 詳細資料（從 https://pokeapi.co/api/v2/pokemon/{id}/）
struct Pokemon: Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let sprites: Sprites
    let stats: [PokemonStat]
    var imageURLString: String? // 從 sprites 提取
}

// UI 用的精簡 Model
struct PokemonSummary {
    let id: Int
    let name: String
    let typeNames: [String]          // 從 types 提取
    let imageURLString: String?      // 從 sprites 提取
    let stats: [StatSummary]         // 包含 name 和 baseStat
}
```

**包含的欄位：**
- ✅ `name` - 從列表 API
- ✅ `id` - 從 URL 提取
- ✅ `types.name` - 從詳細 API
- ✅ `sprites.imageURLString` - 從詳細 API（優先使用 official-artwork）
- ✅ `stats.base_stat` - 從詳細 API
- ✅ `stats.stat.name` - 從詳細 API

### 2. API Layer

#### 主要服務：PokemonAPIService

```swift
let apiService = PokemonAPIService()

// 🌟 推薦：一次取得前 9 個 Pokemon 的完整資料
let summaries = try await apiService.fetchPokemonSummaries(limit: 9, offset: 0)

// 或分步驟取得
let listResponse = try await apiService.fetchPokemonList(limit: 9, offset: 0)
let detail = try await apiService.fetchPokemonDetail(id: 1)
```

#### 特點

1. **並發處理**：使用 `TaskGroup` 同時請求多個 Pokemon 詳細資料
   - 序列請求 9 個：約 9 秒
   - 並發請求 9 個：約 1-2 秒

2. **可測試性**：使用 Protocol 設計，方便注入 Mock
   ```swift
   let mockService = MockNetworkService()
   mockService.mockData = mockJSON.data(using: .utf8)
   let apiService = PokemonAPIService(networkService: mockService)
   ```

3. **錯誤處理**：統一的 `APIError` 類型
   ```swift
   do {
       let summaries = try await apiService.fetchPokemonSummaries(limit: 9)
   } catch let error as APIError {
       print(error.localizedDescription)
   }
   ```

### 3. ViewModel (MVVM)

```swift
class HomeViewModel: ObservableObject {
    @Published var featuredPokemons: [PokemonSummary] = []
    @Published var pokemonTypes: [String] = []
    @Published var regions: [Region] = []
    @Published var isLoadingPokemons = false
    @Published var errorMessage: String?
    
    func loadAllData() {
        loadFeaturedPokemons()  // 載入前 9 個 Pokemon
        loadPokemonTypes()      // 載入所有類型
        loadRegions()           // 載入所有地區
    }
}
```

### 4. View Controller

```swift
class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadAllData()  // 載入所有資料
    }
    
    private func setupBindings() {
        // 使用 Combine 監聽 ViewModel 變化
        viewModel.$featuredPokemons
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}
```

## 使用範例

### 在 HomePage 顯示前 9 個 Pokemon

```swift
// 1. 建立 ViewModel
let viewModel = HomeViewModel()

// 2. 載入資料
viewModel.loadFeaturedPokemons()

// 3. 監聽變化並更新 UI
viewModel.$featuredPokemons
    .sink { pokemons in
        // 更新 UI
        for pokemon in pokemons {
            print("\(pokemon.id): \(pokemon.name)")
            print("Types: \(pokemon.typeNames.joined(separator: ", "))")
            print("Image: \(pokemon.imageURLString ?? "N/A")")
            
            for stat in pokemon.stats {
                print("  \(stat.name): \(stat.baseStat)")
            }
        }
    }
```

### 調整查詢數量

API 使用 `limit` 參數控制數量：

```swift
// 查詢前 9 個（預設）
let summaries = try await apiService.fetchPokemonSummaries(limit: 9, offset: 0)

// 查詢前 20 個
let summaries = try await apiService.fetchPokemonSummaries(limit: 20, offset: 0)

// 查詢第 10-19 個（分頁）
let summaries = try await apiService.fetchPokemonSummaries(limit: 10, offset: 10)
```

## 測試

### 單元測試範例

```swift
@Test func testPokemonSummary() async throws {
    // Given
    let mockService = MockNetworkService()
    mockService.mockData = mockPokemonJSON.data(using: .utf8)
    let apiService = PokemonAPIService(networkService: mockService)
    
    // When
    let response = try await apiService.fetchPokemonList(limit: 1, offset: 0)
    
    // Then
    #expect(response.results.first?.name == "bulbasaur")
    #expect(response.results.first?.id == 1)
}
```

執行測試：
```bash
# 使用 Xcode
⌘ + U

# 或使用命令列
xcodebuild test -scheme PokemonGo -destination 'platform=iOS Simulator,name=iPhone 15'
```

## API 參考

### PokeAPI Endpoints

1. **Pokemon 列表**
   - URL: `https://pokeapi.co/api/v2/pokemon?limit=9&offset=0`
   - 回傳：`PokemonListResponse`

2. **Pokemon 詳細資料**
   - URL: `https://pokeapi.co/api/v2/pokemon/{id}/`
   - 回傳：`Pokemon`

3. **Pokemon Types**
   - URL: `https://pokeapi.co/api/v2/type`
   - 回傳：`PokemonTypeListResponse`

4. **Regions**
   - URL: `https://pokeapi.co/api/v2/region`
   - 回傳：`RegionIndexResponse`

## 效能優化

1. **並發請求**：使用 `TaskGroup` 並發請求多個 Pokemon
2. **圖片快取**：建議使用 `SDWebImage` 或 `Kingfisher` 快取圖片
3. **分頁載入**：使用 `limit` 和 `offset` 實現分頁

## 未來改進

- [ ] 加入圖片快取機制
- [ ] 實作下拉刷新
- [ ] 加入搜尋功能
- [ ] 實作 Pokemon 詳細頁面
- [ ] 加入收藏功能
- [ ] 支援離線模式

## 參考資料

- [PokeAPI Documentation](https://pokeapi.co/docs/v2)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [UICollectionView Compositional Layout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout)

## 授權

MIT License

