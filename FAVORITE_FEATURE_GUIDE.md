# Favorite Feature Implementation Guide

## 問題分析

### 原始問題

你遇到的問題是：

1. **狀態反轉錯誤**：
```swift
// ❌ 錯誤：使用了 !pokemon.isFavorite
self.isFavorite = !pokemon.isFavorite
favoriteButton.isSelected = !pokemon.isFavorite
```

2. **缺少動畫效果**：移除了原本的按鈕動畫

3. **沒有持久化**：狀態沒有儲存到 UserDefaults

## 解決方案

### 1. ✅ 建立 FavoriteManager

**位置**: `PokemonGo/Utilities/FavoriteManager.swift`

**功能**:
- 使用 Singleton 模式管理所有 favorite 狀態
- 使用 UserDefaults 持久化儲存
- 使用 `Set<Int>` 儲存 Pokemon IDs（高效查詢）
- 提供完整的 CRUD 操作

**主要方法**:

```swift
// 檢查是否為 favorite
FavoriteManager.shared.isFavorite(pokemonId: 1) // -> Bool

// 切換 favorite 狀態
FavoriteManager.shared.toggleFavorite(pokemonId: 1) // -> Bool (新狀態)

// 新增 favorite
FavoriteManager.shared.addFavorite(pokemonId: 1)

// 移除 favorite
FavoriteManager.shared.removeFavorite(pokemonId: 1)

// 取得所有 favorite IDs
FavoriteManager.shared.getFavoritePokemonIds() // -> Set<Int>

// 清空所有 favorites
FavoriteManager.shared.clearAllFavorites()
```

### 2. ✅ 更新 PokemonSummary

**位置**: `PokemonGo/Feature/Home/Model/Pokemon.swift`

**修改**:

```swift
extension PokemonSummary {
    init(from pokemon: Pokemon) {
        // ... 其他欄位
        
        // ✅ 從 FavoriteManager 讀取狀態
        self.isFavorite = FavoriteManager.shared.isFavorite(pokemonId: pokemon.id)
    }
}
```

**優點**:
- 每次建立 `PokemonSummary` 時自動從 UserDefaults 讀取最新狀態
- 確保狀態一致性

### 3. ✅ 修正 PokemonCell

**位置**: `PokemonGo/Feature/Home/Views/PokemonCell.swift`

**修改前**:
```swift
// ❌ 錯誤：狀態反轉
self.isFavorite = !pokemon.isFavorite
favoriteButton.isSelected = !pokemon.isFavorite

return favoriteButton.tapPublisher
    .map({ HomeViewModel.Input.favoritePokemonsUpdated(...) })
    .eraseToAnyPublisher()
```

**修改後**:
```swift
// ✅ 正確：直接使用 pokemon.isFavorite
self.isFavorite = pokemon.isFavorite
favoriteButton.isSelected = pokemon.isFavorite

return favoriteButton.tapPublisher
    .handleEvents(receiveOutput: { [weak self] _ in
        guard let self = self else { return }
        
        // 1. Toggle UI state
        self.isFavorite.toggle()
        self.favoriteButton.isSelected = self.isFavorite
        
        // 2. Save to UserDefaults
        FavoriteManager.shared.toggleFavorite(pokemonId: pokemon.id)
        
        // 3. Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    })
    .map { _ in HomeViewModel.Input.favoritePokemonsUpdated(...) }
    .eraseToAnyPublisher()
```

**改進點**:
1. ✅ 正確設定初始狀態
2. ✅ 使用 `handleEvents` 處理副作用（動畫、儲存）
3. ✅ 保持 Combine 風格
4. ✅ 加回按鈕動畫效果

## 資料流程

### 載入時

```
1. API 回傳 Pokemon data
   ↓
2. 建立 PokemonSummary
   ↓
3. 從 FavoriteManager 讀取 isFavorite 狀態
   ↓
4. Cell configure 時設定 UI
```

### 點擊 Favorite 按鈕時

```
1. User 點擊 heart 按鈕
   ↓
2. tapPublisher 發出事件
   ↓
3. handleEvents 執行：
   - Toggle UI state
   - 儲存到 UserDefaults (via FavoriteManager)
   - 播放動畫
   ↓
4. map 轉換為 ViewModel Input
   ↓
5. ViewModel 處理 (如果需要)
```

## 使用範例

### 在 Cell 中使用

```swift
// HomeViewController.swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(...) as! PokemonCell
    
    if let pokemon = viewModel.pokemon(at: indexPath.item) {
        // configure 會自動處理 favorite 狀態
        cell.configure(with: pokemon)
            .sink { [weak self] input in
                self?.event.send(input)
            }
            .store(in: &cell.cancellables)
    }
    
    return cell
}
```

### 在其他地方使用 FavoriteManager

```swift
// 檢查某個 Pokemon 是否為 favorite
let isFavorite = FavoriteManager.shared.isFavorite(pokemonId: 25) // Pikachu

// 取得所有 favorite Pokemon IDs
let favoriteIds = FavoriteManager.shared.getFavoritePokemonIds()
print("Total favorites: \(favoriteIds.count)")

// 過濾出 favorite Pokemon
let favoritePokemons = allPokemons.filter { pokemon in
    FavoriteManager.shared.isFavorite(pokemonId: pokemon.id)
}
```

## 資料持久化

### UserDefaults 結構

```swift
Key: "favoritePokemonIds"
Value: JSON encoded Set<Int>

Example:
{
    "favoritePokemonIds": [1, 4, 7, 25, 133, 150]
}
```

### 優點

1. **簡單**: 使用 UserDefaults，不需要 Core Data
2. **高效**: 使用 `Set<Int>` 查詢 O(1)
3. **可靠**: JSON encode/decode 確保資料完整性
4. **輕量**: 只儲存 Pokemon IDs

### 限制

- UserDefaults 適合儲存少量資料（< 1MB）
- 如果 favorite 數量很大（> 1000），建議改用 Core Data

## 測試

### 測試 FavoriteManager

```swift
func testFavoriteManager() {
    let manager = FavoriteManager.shared
    
    // 清空
    manager.clearAllFavorites()
    
    // 測試新增
    manager.addFavorite(pokemonId: 1)
    XCTAssertTrue(manager.isFavorite(pokemonId: 1))
    
    // 測試 toggle
    let newState = manager.toggleFavorite(pokemonId: 1)
    XCTAssertFalse(newState)
    XCTAssertFalse(manager.isFavorite(pokemonId: 1))
    
    // 測試多個
    manager.addFavorite(pokemonId: 1)
    manager.addFavorite(pokemonId: 25)
    manager.addFavorite(pokemonId: 150)
    
    let favorites = manager.getFavoritePokemonIds()
    XCTAssertEqual(favorites.count, 3)
    XCTAssertTrue(favorites.contains(1))
    XCTAssertTrue(favorites.contains(25))
    XCTAssertTrue(favorites.contains(150))
}
```

### 測試 UI

1. **初始狀態**: 開啟 App，確認 heart 按鈕狀態正確
2. **點擊測試**: 點擊 heart，確認：
   - 按鈕狀態改變（空心 ↔ 實心）
   - 有縮放動畫
   - 狀態被儲存
3. **持久化測試**: 
   - 點擊幾個 Pokemon 的 heart
   - 關閉 App
   - 重新開啟 App
   - 確認 heart 狀態保持

## 未來改進

### 1. 加入 Favorite 列表頁面

```swift
class FavoriteViewController: UIViewController {
    func loadFavoritePokemons() {
        let favoriteIds = FavoriteManager.shared.getFavoritePokemonIds()
        let favoritePokemons = allPokemons.filter { favoriteIds.contains($0.id) }
        // Display favoritePokemons
    }
}
```

### 2. 加入同步功能

```swift
// 與 iCloud 同步
extension FavoriteManager {
    func syncWithiCloud() {
        // Use NSUbiquitousKeyValueStore
    }
}
```

### 3. 加入通知

```swift
extension FavoriteManager {
    static let favoriteDidChangeNotification = Notification.Name("favoriteDidChange")
    
    func toggleFavorite(pokemonId: Int) -> Bool {
        // ... toggle logic
        
        NotificationCenter.default.post(
            name: Self.favoriteDidChangeNotification,
            object: nil,
            userInfo: ["pokemonId": pokemonId, "isFavorite": newState]
        )
        
        return newState
    }
}
```

## 總結

✅ **問題已解決**:
1. ✅ 修正狀態反轉錯誤
2. ✅ 加回按鈕動畫
3. ✅ 實作 UserDefaults 持久化
4. ✅ 建立 FavoriteManager 統一管理
5. ✅ 保持 Combine 風格
6. ✅ 正確處理 memory management

**現在 Favorite 功能完全正常運作！** 🎉

- 點擊 heart 按鈕會正確切換狀態
- 狀態會儲存到 UserDefaults
- 重新開啟 App 後狀態保持
- 有流暢的動畫效果

