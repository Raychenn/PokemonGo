# 🎮 PokemonGo iOS App

A modern iOS application that displays Pokemon data from the [PokeAPI](https://pokeapi.co/), featuring a beautiful UI with both UIKit and SwiftUI components.

## 📱 Features

### Home Screen
- **Featured Pokemon**: Horizontally scrollable cards showing the first 9 Pokemon with pagination (3 per page)
- **Pokemon Types**: Browse all available Pokemon types
- **Regions**: View Pokemon regions with location counts
- **Favorite System**: Mark Pokemon as favorites with persistent storage using UserDefaults

### Pokemon Detail View
- **SwiftUI Implementation**: Modern SwiftUI-based detail screen
- **Gradient Header**: Dynamic gradient background based on Pokemon's primary type
- **Stats Display**: Visual representation of Pokemon base stats with progress bars
- **Liquid Glass Effect**: iOS 18+ glass morphism design for UI elements
- **Smooth Scrolling**: Custom navigation bar behavior with scroll-based transitions
- **Favorite Toggle**: Quick favorite/unfavorite with animated SF Symbols

### Pokemon List (See More)
- **Pagination**: Load 20 Pokemon at a time with infinite scroll
- **SwiftUI List**: Efficient lazy loading with Kingfisher image caching
- **Navigation**: Seamless navigation to detail view

## 🏗️ Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Combine Framework**: Reactive programming for data binding and event handling
- **Swift Concurrency**: Modern async/await for API calls

### Tech Stack
- **UIKit**: Main home screen with UICollectionView compositional layout
- **SwiftUI**: Detail view and list view
- **Combine**: Reactive data flow and event handling
- **SnapKit**: Programmatic Auto Layout
- **Kingfisher**: Async image loading and caching

## 📦 Dependencies

```swift
dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.0")
]
```

## 🎨 UI Highlights

### Custom Components
- **PokemonCell**: Custom collection view cell with type-based color theming
- **TypesCell**: Pill-shaped type badges with custom colors
- **RegionsCell**: Region cards with location counts
- **SectionHeaderView**: Reusable header with "See more" button

### Design Features
- ✨ Type-based color schemes (Grass, Fire, Water, etc.)
- 🎭 Smooth animations and transitions
- 📐 Rounded corners and shadows for depth
- 🌊 Liquid glass effect (iOS 18+)
- 🎯 SF Symbols with symbol effects

## 🔧 API Integration

### Network Layer
```
PokemonGo/
├── Network/
│   ├── NetworkService.swift          # Generic network service
│   ├── PokemonAPIService.swift       # Pokemon-specific API calls
│   ├── PokemonEndpoint.swift         # API endpoints
│   ├── APIError.swift                # Error handling
│   └── MockNetworkService.swift      # Testing support
```

### Key Features
- Protocol-oriented design for testability
- Concurrent API calls using TaskGroup
- Proper error handling
- Dependency injection support

## 📁 Project Structure

```
PokemonGo/
├── Feature/
│   ├── Home/
│   │   ├── Controller/
│   │   │   ├── HomeViewController.swift
│   │   │   └── HomeViewController+UICollectionView.swift
│   │   ├── Model/
│   │   │   ├── Pokemon.swift
│   │   │   ├── PokemonType.swift
│   │   │   └── Region.swift
│   │   ├── ViewModel/
│   │   │   └── HomeViewModel.swift
│   │   └── Views/
│   │       ├── PokemonCell.swift
│   │       ├── TypesCell.swift
│   │       ├── RegionsCell.swift
│   │       ├── SectionHeaderView.swift
│   │       └── Detail/
│   │           └── PokemonDetailView.swift
│   └── SeeMore/
│       ├── SeeMorePokemonView.swift
│       └── SeeMorePokemonViewModel.swift
├── Network/
│   └── [API Layer Files]
├── Utilities/
│   └── UserDefaultManager.swift
└── Extensions/
    └── Array+Extensions.swift
```

## 🚀 Getting Started

### Requirements
- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/PokemonGo.git
cd PokemonGo
```

2. Open the project in Xcode
```bash
open PokemonGo.xcodeproj
```

3. Build and run
- Select a simulator or device
- Press `Cmd + R` to build and run

### Swift Package Dependencies
Dependencies will be automatically resolved by Xcode on first build.

## 🎯 Key Implementation Details

### MVVM with Combine
```swift
// ViewModel publishes data
@Published var pokemons: [PokemonSummary] = []

// View subscribes to changes
viewModel.$pokemons
    .sink { [weak self] pokemons in
        self?.updateUI(with: pokemons)
    }
    .store(in: &cancellables)
```

### Pagination
```swift
func shouldLoadMore(currentItem: PokemonSummary) -> Bool {
    guard let lastItem = pokemons.last else { return false }
    return currentItem.id == lastItem.id && hasMoreData && !isLoading
}
```

### Type-Based Theming
```swift
private func getTypeColor(for type: String) -> UIColor {
    switch type.lowercased() {
    case "grass": return UIColor(red: 0.48, green: 0.78, blue: 0.48, alpha: 1.0)
    case "fire": return UIColor(red: 0.93, green: 0.51, blue: 0.29, alpha: 1.0)
    // ... more types
    }
}
```

## 📸 Screenshots

> Add screenshots here to showcase your app

## 🧪 Testing

The project includes:
- Protocol-oriented design for easy mocking
- `MockNetworkService` for testing API calls
- Testable ViewModels with dependency injection

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is available under the MIT License.

## 🙏 Acknowledgments

- [PokeAPI](https://pokeapi.co/) - The RESTful Pokemon API
- [Kingfisher](https://github.com/onevcat/Kingfisher) - Image downloading and caching
- [SnapKit](https://github.com/SnapKit/SnapKit) - Auto Layout DSL
- [CombineCocoa](https://github.com/CombineCommunity/CombineCocoa) - Combine extensions for Cocoa

---

Made with ❤️ using Swift and SwiftUI

