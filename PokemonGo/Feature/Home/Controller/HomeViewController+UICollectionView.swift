//
//  HomeViewController+UICollectionView.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/16.
//

import UIKit
import SwiftUI

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
                let position = viewModel.pokemonCellPosition(at: indexPath.item)
                
                cell.configure(with: pokemon, position: position)
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
                withReuseIdentifier: String(describing: SectionHeaderView.self),
                for: indexPath
              ) as? SectionHeaderView,
              let section = HomeViewModel.Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        headerView.configure(title: section.title, showSeeMore: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleSeeMore(for: section)
            }
            .store(in: &headerView.cancellables)
        
        return headerView
    }
    
    private func handleSeeMore(for section: HomeViewModel.Section) {
        switch section {
        case .feature:
            // Navigate to See More Pokemon View (SwiftUI)
            let seeMoreView = SeeMorePokemonView()
            let hostingController = UIHostingController(rootView: seeMoreView)
            navigationController?.pushViewController(hostingController, animated: true)
        case .types:
            print("See more tapped for Types section")
            // TODO: Navigate to types screen
        case .regions:
            print("See more tapped for Regions section")
            // TODO: Navigate to regions screen
        }
    }
}


// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .feature:
            if let pokemon = viewModel.pokemon(at: indexPath.item) {
                let detailView = PokemonDetailView(pokemon: pokemon)
                let hostingController = UIHostingController(rootView: detailView)
                hostingController.navigationItem.hidesBackButton = true
                
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

