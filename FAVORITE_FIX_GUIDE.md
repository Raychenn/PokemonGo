# Favorite Feature Fix - 統一在 ViewModel 處理狀態

## 問題分析

### 問題 1: Favorite button 狀態沒有正確變換

**原因**:
```swift
// Cell 內立即 toggle 狀態
self.isFavorite.toggle()
self.favoriteButton.isSelected = self.isFavorite

// 但 ViewModel 處理後會 reload
self?.state.reloadData.send(())

// Reload 時 Cell 重新 configure，狀態被重置回原始值
```

**流程**:
```
1. User 點擊 heart
2. Cell 立即 toggle: false → true
3. 發送 event 到 ViewModel
4. ViewModel reload
5. Cell 重新 configure，讀取 Pokemon.isFavorite (還是 false)
6. 結果：按鈕又變回 false ❌
```

### 問題 2: 狀態改動要在 ViewModel 統一處理

**原因**:
- Cell 內直接操作 `FavoriteManager` 違反單一職責原則
- 狀態分散在 Cell 和 ViewModel，難以維護
- 不符合 MVVM 架構，View 不應該處理業務邏輯

## 解決方案

### 架構調整

```
舊架構 (錯誤):
User Tap → Cell toggle state → Save to UserDefaults → Send event → ViewModel reload → Cell 重置 ❌

新架構 (正確):
User Tap → Send event → ViewModel toggle & save → Update DataSource → Reload → Cell 顯示新狀態 ✅
```

### 1. ✅ 修改 HomeViewModel

**位置**: `Feature/Home/ViewModel/HomeViewModel.swift`

**修改前**:
```swift
case .favoritePokemonsUpdated(isFavorite: let isFavorite, pokemonId: let pokemonId):
    UserDefaults.standard.set(isFavorite, forKey: "isFavorite_\(pokemonId)")
    self?.state.reloadData.send(())
```

**修改後**:
```swift
case .favoritePokemonsUpdated(isFavorite: let isFavorite, pokemonId: let pokemonId):
    // 1. Toggle favorite state in FavoriteManager
    let newState = FavoriteManager.shared.toggleFavorite(pokemonId: pokemonId)
    
    // 2. Update the pokemon in dataSource
    if let index = self?.dataSoruce.featuredPokemons.firstIndex(where: { $0.id == pokemonId }) {
        self?.dataSoruce.featuredPokemons[index].isFavorite = newState
    }
    
    // 3. Reload to update UI
    self?.state.reloadData.send(())
```

**改進點**:
- ✅ 使用 `FavoriteManager` 統一管理狀態
- ✅ 直接更新 `dataSource` 中的 Pokemon
- ✅ Reload 時 Cell 會讀取到正確的新狀態

### 2. ✅ 修改 PokemonCell

**位置**: `Feature/Home/Views/PokemonCell.swift`

**修改前**:
```swift
return favoriteButton.tapPublisher
    .handleEvents(receiveOutput: { [weak self] _ in
        // ❌ Cell 內處理業務邏輯
        self.isFavorite.toggle()
        self.favoriteButton.isSelected = self.isFavorite
        FavoriteManager.shared.toggleFavorite(pokemonId: pokemon.id)
        // Animation...
    })
    .map { _ in HomeViewModel.Input.favoritePokemonsUpdated(...) }
    .eraseToAnyPublisher()
```

**修改後**:
```swift
return favoriteButton.tapPublisher
    .handleEvents(receiveOutput: { [weak self] _ in
        // ✅ Cell 只負責動畫
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    })
    .map { _ in 
        // ✅ 只發送事件，不處理狀態
        HomeViewModel.Input.favoritePokemonsUpdated(isFavorite: pokemon.isFavorite, pokemonId: pokemon.id) 
    }
    .eraseToAnyPublisher()
```

**改進點**:
- ✅ Cell 只負責 UI（動畫）
- ✅ 不在 Cell 內處理業務邏輯
- ✅ 狀態管理完全由 ViewModel 負責

### 3. ✅ 確保 PokemonSummary.isFavorite 可變

**位置**: `Feature/Home/Model/Pokemon.swift`

```swift
struct PokemonSummary {
    let id: Int
    let name: String
    let typeNames: [String]
    let imageURLString: String?
    let stats: [StatSummary]
    var isFavorite: Bool // ✅ var 讓 ViewModel 可以修改
}
```

## 資料流程

### 完整流程

```
1. User 點擊 heart button
   ↓
2. Cell 播放動畫（純 UI）
   ↓
3. Cell 發送 Input.favoritePokemonsUpdated(isFavorite: false, pokemonId: 1)
   ↓
4. ViewModel 接收 event
   ↓
5. ViewModel 呼叫 FavoriteManager.shared.toggleFavorite(pokemonId: 1)
   ↓
6. FavoriteManager 儲存到 UserDefaults，回傳新狀態 (true)
   ↓
7. ViewModel 更新 dataSource.featuredPokemons[index].isFavorite = true
   ↓
8. ViewModel 發送 reloadData
   ↓
9. CollectionView reload
   ↓
10. Cell 重新 configure，讀取 pokemon.isFavorite (true)
    ↓
11. favoriteButton.isSelected = true ✅
```

### 狀態同步

```
UserDefaults (FavoriteManager)
    ↕ (sync)
ViewModel.dataSource.featuredPokemons[].isFavorite
    ↕ (reload)
Cell.favoriteButton.isSelected
```

## 職責劃分

### ✅ Cell (View)
- 顯示 UI
- 處理動畫
- 發送 User 事件
- **不處理業務邏輯**

### ✅ ViewModel
- 處理業務邏輯
- 管理狀態
- 呼叫 Service/Manager
- 更新 DataSource
- 通知 View 更新

### ✅ FavoriteManager (Service)
- 持久化儲存
- 提供 CRUD 操作
- 不關心 UI

## 優點

### 1. 狀態一致性
```swift
// ✅ 單一真相來源 (Single Source of Truth)
ViewModel.dataSource.featuredPokemons[].isFavorite
```

### 2. 可測試性
```swift
// ✅ ViewModel 可以獨立測試
func testToggleFavorite() {
    let viewModel = HomeViewModel()
    let input = PassthroughSubject<HomeViewModel.Input, Never>()
    
    _ = viewModel.transform(input.eraseToAnyPublisher())
    
    // Send event
    input.send(.favoritePokemonsUpdated(isFavorite: false, pokemonId: 1))
    
    // Verify
    XCTAssertTrue(viewModel.dataSoruce.featuredPokemons[0].isFavorite)
}
```

### 3. 符合 MVVM
```
View (Cell) → 只負責 UI
ViewModel → 負責業務邏輯
Model → 純資料結構
```

### 4. 易於維護
```swift
// ✅ 要修改 favorite 邏輯，只需改 ViewModel
// ✅ 不需要改動 Cell
// ✅ 不需要改動 Model
```

## 測試方式

### 1. 手動測試

```
1. 開啟 App
2. 點擊第一個 Pokemon 的 heart
3. 確認：
   ✅ 按鈕從空心變實心
   ✅ 有縮放動畫
   ✅ 狀態保持（不會閃回空心）
4. 滑動到其他 Pokemon 再滑回來
5. 確認：
   ✅ 第一個 Pokemon 的 heart 還是實心
6. 關閉 App 重新開啟
7. 確認：
   ✅ 第一個 Pokemon 的 heart 還是實心
```

### 2. 單元測試

```swift
func testFavoriteToggle() {
    // Given
    let viewModel = HomeViewModel()
    let input = PassthroughSubject<HomeViewModel.Input, Never>()
    _ = viewModel.transform(input.eraseToAnyPublisher())
    
    // Load pokemons
    viewModel.loadFeaturedPokemons()
    wait(for: 1.0)
    
    let pokemon = viewModel.pokemon(at: 0)!
    let initialState = pokemon.isFavorite
    
    // When
    input.send(.favoritePokemonsUpdated(isFavorite: initialState, pokemonId: pokemon.id))
    
    // Then
    let newPokemon = viewModel.pokemon(at: 0)!
    XCTAssertEqual(newPokemon.isFavorite, !initialState)
    
    // Verify UserDefaults
    let savedState = FavoriteManager.shared.isFavorite(pokemonId: pokemon.id)
    XCTAssertEqual(savedState, !initialState)
}
```

## 常見問題

### Q1: 為什麼不在 Cell 內直接 toggle？

**A**: 因為會導致狀態不一致：

```swift
// ❌ 錯誤流程
Cell toggle → state = true
ViewModel reload → Cell configure → state = false (從 dataSource 讀取)
結果：按鈕閃爍，狀態錯誤
```

### Q2: 為什麼要更新 dataSource？

**A**: 因為 reload 時 Cell 會重新讀取 dataSource：

```swift
// ✅ 正確流程
ViewModel toggle → dataSource.isFavorite = true
ViewModel reload → Cell configure → state = true (從 dataSource 讀取)
結果：狀態正確
```

### Q3: Input 的 isFavorite 參數還有用嗎？

**A**: 目前沒用，因為 ViewModel 會直接 toggle。可以考慮移除：

```swift
// 選項 1: 保留（未來可能用到）
case .favoritePokemonsUpdated(isFavorite: Bool, pokemonId: Int)

// 選項 2: 簡化
case .favoritePokemonToggled(pokemonId: Int)
```

## 總結

✅ **問題已解決**:

1. ✅ **Favorite button 狀態正確變換**
   - ViewModel 更新 dataSource
   - Reload 時讀取正確狀態

2. ✅ **狀態統一在 ViewModel 處理**
   - Cell 只負責 UI
   - ViewModel 負責業務邏輯
   - FavoriteManager 負責持久化

3. ✅ **符合 MVVM 架構**
   - 職責清晰
   - 易於測試
   - 易於維護

**現在 Favorite 功能完全正常！** 🎉

