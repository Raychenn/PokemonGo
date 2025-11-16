//
//  ViewController.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/14.
//

import UIKit
import Combine
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let event = PassthroughSubject<HomeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
        guard let section = HomeViewModel.Section(rawValue: sectionIndex) else {
            return self?.emptySection
        }
        return self?.compositionalLayout(for: section)
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = HomeViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        event.send(.lifeCycele(.viewIsAppearing))
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Pokédex"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Register cells
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: String(describing: PokemonCell.self))
        collectionView.register(TypesCell.self, forCellWithReuseIdentifier: String(describing: TypesCell.self))
        collectionView.register(RegionsCell.self, forCellWithReuseIdentifier: String(describing: RegionsCell.self))
        
        // Register header
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
    }
    
    private func setupBindings() {
        
        let output = viewModel.transform(event.eraseToAnyPublisher())
        
        output.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        output.reloadData
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        output.$errorMessage
            .sink { [weak self] message in
                guard let message, !message.isEmpty else { return }
                self?.showError(message)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Layout
    
    private func compositionalLayout(for section: HomeViewModel.Section) -> NSCollectionLayoutSection {
        switch section {
        case .feature:
            return featureSection
        case .types:
            return typeSection
        case .regions:
            return regionSection
        }
    }
    
    private var emptySection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private var featureSection: NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group - 3 items per page
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .estimated(380)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item, item, item]
        )
        group.interItemSpacing = .fixed(8)
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private var typeSection: NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private var regionSection: NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group - 2 items per row
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        // Section - Static, no scrolling
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .feature:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PokemonCell.self),
                for: indexPath
            ) as? PokemonCell else {
                return UICollectionViewCell()
            }
            
            if let pokemon = viewModel.pokemon(at: indexPath.item) {
                cell.configure(with: pokemon)
                    .subscribe(event)
                    .store(in: &cell.cancellables)
            }
            return cell
            
        case .types:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TypesCell.self),
                for: indexPath
            ) as? TypesCell else {
                return UICollectionViewCell()
            }
            
            if let type = viewModel.type(at: indexPath.item) {
                cell.configure(with: type)
            }
            return cell
            
        case .regions:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: RegionsCell.self),
                for: indexPath
            ) as? RegionsCell else {
                return UICollectionViewCell()
            }
            
            if let region = viewModel.region(at: indexPath.item) {
                cell.configure(with: region)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? SectionHeaderView,
              let section = HomeViewModel.Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        headerView.configure(title: section.title, showSeeMore: true)
        headerView.onSeeMoreTapped = { [weak self] in
            self?.handleSeeMore(for: section)
        }
        
        return headerView
    }
    
    private func handleSeeMore(for section: HomeViewModel.Section) {
        print("See more tapped for section: \(section.title)")
        // TODO: Navigate to detail screen
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .feature:
            if let pokemon = viewModel.pokemon(at: indexPath.item) {
                // Navigate to SwiftUI detail screen
                let detailView = PokemonDetailView(pokemon: pokemon)
                let hostingController = UIHostingController(rootView: detailView)
                navigationController?.pushViewController(hostingController, animated: true)
            }
            
        case .types:
            if let type = viewModel.type(at: indexPath.item) {
                print("Selected Type: \(type)")
                // TODO: Filter by type
            }
            
        case .regions:
            if let region = viewModel.region(at: indexPath.item) {
                print("Selected Region: \(region.name)")
                // TODO: Navigate to region detail
            }
        }
    }
}




