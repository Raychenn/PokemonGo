# Pokemon Go UI Implementation Guide

## 完成項目 ✅

根據設計圖，已完整實作以下功能：

### 1. Custom Cells

#### ✅ PokemonCell
- **位置**: `Feature/Home/Views/PokemonCell.swift`
- **功能**:
  - 顯示 Pokemon 圖片（使用 Kingfisher 載入和快取）
  - 顯示 Pokemon 編號（#1, #2...）
  - 顯示 Pokemon 名稱（大寫）
  - 顯示 Type 標籤（Grass, Poison 等，帶顏色）
  - 右下角 Favorite 按鈕（使用 SF Symbol heart/heart.fill）
  - 背景顏色根據主要 Type 自動調整
  - 完整的 reuse 處理，避免圖片重複問題

#### ✅ TypesCell
- **位置**: `Feature/Home/Views/TypesCell.swift`
- **功能**:
  - 顯示 Type 名稱
  - 背景顏色根據 Type 自動調整
  - 圓角設計

#### ✅ RegionsCell
- **位置**: `Feature/Home/Views/RegionsCell.swift`
- **功能**:
  - 顯示 Region 名稱
  - 顯示 Location 數量
  - 簡潔的卡片設計

### 2. Section Header

#### ✅ SectionHeaderView
- **位置**: `Feature/Home/Views/SectionHeaderView.swift`
- **功能**:
  - 顯示 Section 標題
  - "See more" 按鈕（可點擊）
  - 使用 StackView 排版

### 3. Layout 設計

#### ✅ Featured Pokemon Section
- **特點**:
  - 每頁顯示 3 個 Pokemon
  - 可左右滑動（groupPaging）
  - 使用 SnapKit 佈局
  - 完整的 Section Header

#### ✅ Types Section
- **特點**:
  - 可左右連續滑動
  - 每個 Type 固定寬度 140pt
  - 顯示所有 Pokemon Types
  - 完整的 Section Header

#### ✅ Regions Section
- **特點**:
  - **固定顯示前 6 個 Region**
  - **不可滑動**（靜態呈現）
  - 2 欄式佈局
  - 完整的 Section Header

### 4. 技術實作

#### ✅ SnapKit
所有 Cell 和 View 都使用 SnapKit 進行佈局：

```swift
containerView.snp.makeConstraints { make in
    make.edges.equalToSuperview().inset(4)
}

pokemonImageView.snp.makeConstraints { make in
    make.leading.equalToSuperview().offset(12)
    make.centerY.equalToSuperview()
    make.width.height.equalTo(80)
}
```

#### ✅ Kingfisher
圖片載入使用 Kingfisher，包含：
- 自動快取
- Fade 動畫
- Placeholder 顯示
- 正確的 reuse 處理

```swift
pokemonImageView.kf.setImage(
    with: url,
    placeholder: UIImage(systemName: "photo"),
    options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage
    ]
)
```

#### ✅ Stack View
大量使用 StackView 簡化 UI：
- PokemonCell 的 Type 標籤
- RegionsCell 的垂直排列
- SectionHeaderView 的水平排列

#### ✅ Reuse 處理
所有 Cell 都實作了 `prepareForReuse()`：

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    pokemonImageView.kf.cancelDownloadTask()  // 取消下載
    pokemonImageView.image = nil               // 清空圖片
    typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    // ... 清空其他內容
}
```

### 5. 顏色系統

#### ✅ Type Colors
完整實作 18 種 Pokemon Type 顏色：

| Type | Color |
|------|-------|
| Grass | 🟢 Green |
| Poison | 🟣 Purple |
| Fire | 🔴 Red-Orange |
| Water | 🔵 Blue |
| Electric | ⚡ Yellow |
| Normal | ⚪ Gray |
| Fighting | 🥊 Dark Red |
| Flying | 🦅 Light Purple |
| Ground | 🟤 Brown-Yellow |
| Rock | 🪨 Brown-Gray |
| Bug | 🐛 Yellow-Green |
| Ghost | 👻 Dark Purple |
| Steel | ⚙️ Gray-Blue |
| Psychic | 🔮 Pink |
| Ice | ❄️ Cyan |
| Dragon | 🐉 Blue-Purple |
| Dark | 🌑 Dark Brown |
| Fairy | 🧚 Pink |

### 6. UI 特點

#### ✅ Featured Pokemon
- 左邊：Pokemon 圖片（80x80，圓角背景）
- 中間：編號、名稱、Type 標籤
- 右上：Pokeball 圖示
- 右下：Favorite 按鈕（可點擊，有動畫）
- 背景：根據主要 Type 調整透明度

#### ✅ Types
- 簡潔的卡片設計
- 白色文字
- Type 顏色背景
- 圓角 16pt

#### ✅ Regions
- 白色卡片
- 灰色邊框
- 垂直排列：名稱 + Location 數量
- 2 欄式佈局

## 使用方式

### 在 HomeViewController 中

```swift
// 1. 註冊 Cells
collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.reuseIdentifier)
collectionView.register(TypesCell.self, forCellWithReuseIdentifier: TypesCell.reuseIdentifier)
collectionView.register(RegionsCell.self, forCellWithReuseIdentifier: RegionsCell.reuseIdentifier)

// 2. 註冊 Header
collectionView.register(
    SectionHeaderView.self,
    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
    withReuseIdentifier: SectionHeaderView.reuseIdentifier
)

// 3. 使用 Cell
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch section {
    case .feature:
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PokemonCell.reuseIdentifier,
            for: indexPath
        ) as! PokemonCell
        
        cell.configure(with: pokemon, isFavorite: false) { isFavorite in
            // Handle favorite toggle
        }
        return cell
    }
}
```

### Favorite 功能

```swift
cell.configure(with: pokemon, isFavorite: false) { isFavorite in
    print("Pokemon \(pokemon.name) favorite: \(isFavorite)")
    // TODO: Save to UserDefaults or Core Data
}
```

### See More 功能

```swift
headerView.onSeeMoreTapped = { [weak self] in
    self?.handleSeeMore(for: section)
}

private func handleSeeMore(for section: HomeViewModel.Section) {
    switch section {
    case .feature:
        // Navigate to all Pokemon list
    case .types:
        // Navigate to all types
    case .regions:
        // Navigate to all regions
    }
}
```

## Layout 規格

### Featured Pokemon Section
```swift
- Item: .fractionalWidth(1), .estimated(120)
- Group: .fractionalWidth(0.9), .estimated(380), vertical, 3 items
- Section: groupPaging, spacing 16
- ContentInsets: (8, 16, 16, 16)
```

### Types Section
```swift
- Item: .fractionalWidth(1), .fractionalHeight(1)
- Group: .absolute(140), .absolute(100)
- Section: continuous scrolling, spacing 12
- ContentInsets: (8, 16, 16, 16)
```

### Regions Section
```swift
- Item: .fractionalWidth(0.5), .absolute(100)
- Group: .fractionalWidth(1), .absolute(100), 2 items
- Section: static (no scrolling)
- ContentInsets: (8, 16, 16, 16)
```

## 檔案結構

```
PokemonGo/Feature/Home/Views/
├── PokemonCell.swift          ✅ Featured Pokemon Cell
├── TypesCell.swift            ✅ Types Cell
├── RegionsCell.swift          ✅ Regions Cell
└── SectionHeaderView.swift    ✅ Section Header
```

## 依賴套件

- **SnapKit**: Auto Layout DSL
- **Kingfisher**: 圖片載入和快取

## 注意事項

### ✅ 已處理的問題

1. **圖片 Reuse 問題**: 使用 `prepareForReuse()` 和 `kf.cancelDownloadTask()`
2. **Type 標籤重複**: 每次 configure 前清空 StackView
3. **Memory Leak**: 使用 `[weak self]` 和正確的 closure 處理
4. **Regions 數量**: ViewModel 中限制只取前 6 個
5. **滑動行為**: 
   - Featured Pokemon: groupPaging
   - Types: continuous
   - Regions: 無滑動（靜態）

### 未來改進

- [ ] 實作 Favorite 功能的持久化（UserDefaults/Core Data）
- [ ] 加入 Pokemon 詳細頁面
- [ ] 實作 See More 導航
- [ ] 加入下拉刷新
- [ ] 加入搜尋功能
- [ ] 優化圖片載入效能

## 測試建議

1. **測試 Cell Reuse**:
   - 快速滑動，確認圖片不會錯亂
   - 確認 Type 標籤不會重複

2. **測試 Favorite**:
   - 點擊 heart 按鈕
   - 確認動畫正常
   - 確認狀態切換

3. **測試 Layout**:
   - 不同螢幕尺寸
   - 橫向/直向
   - 確認 Regions 只顯示 6 個

4. **測試效能**:
   - 圖片快取是否生效
   - 滑動是否流暢
   - Memory 使用是否正常

## 總結

✅ 所有需求都已完成：
1. ✅ 建立 PokemonCell, TypesCell, RegionsCell
2. ✅ Featured Pokemon 和 Types 可左右滑動
3. ✅ Regions 固定顯示前 6 個，不可滑動
4. ✅ Section Header 顯示標題和 See more 按鈕
5. ✅ 使用 SnapKit 和 StackView
6. ✅ 使用 Kingfisher 處理圖片（含快取）
7. ✅ 正確處理 Reuse 問題
8. ✅ Favorite 按鈕使用 SF Symbol heart/heart.fill
9. ✅ 完整的 Type 顏色系統

程式碼已準備好運行和測試！🎉

