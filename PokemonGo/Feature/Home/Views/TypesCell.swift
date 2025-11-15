//
//  TypesCell.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import UIKit
import SnapKit

class TypesCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TypesCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(typeLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with typeName: String) {
        typeLabel.text = typeName.capitalized
        containerView.backgroundColor = getTypeColor(for: typeName)
    }
    
    private func getTypeColor(for type: String) -> UIColor {
        switch type.lowercased() {
        case "grass": return UIColor(red: 0.48, green: 0.78, blue: 0.48, alpha: 1.0)
        case "poison": return UIColor(red: 0.64, green: 0.44, blue: 0.68, alpha: 1.0)
        case "fire": return UIColor(red: 0.93, green: 0.51, blue: 0.29, alpha: 1.0)
        case "water": return UIColor(red: 0.39, green: 0.56, blue: 0.93, alpha: 1.0)
        case "electric": return UIColor(red: 0.98, green: 0.84, blue: 0.25, alpha: 1.0)
        case "normal": return UIColor(red: 0.66, green: 0.66, blue: 0.47, alpha: 1.0)
        case "fighting": return UIColor(red: 0.75, green: 0.19, blue: 0.15, alpha: 1.0)
        case "flying": return UIColor(red: 0.66, green: 0.56, blue: 0.95, alpha: 1.0)
        case "ground": return UIColor(red: 0.89, green: 0.75, blue: 0.42, alpha: 1.0)
        case "rock": return UIColor(red: 0.72, green: 0.63, blue: 0.42, alpha: 1.0)
        case "bug": return UIColor(red: 0.66, green: 0.73, blue: 0.13, alpha: 1.0)
        case "ghost": return UIColor(red: 0.44, green: 0.35, blue: 0.60, alpha: 1.0)
        case "steel": return UIColor(red: 0.72, green: 0.72, blue: 0.82, alpha: 1.0)
        case "psychic": return UIColor(red: 0.98, green: 0.33, blue: 0.45, alpha: 1.0)
        case "ice": return UIColor(red: 0.60, green: 0.85, blue: 0.85, alpha: 1.0)
        case "dragon": return UIColor(red: 0.44, green: 0.21, blue: 0.99, alpha: 1.0)
        case "dark": return UIColor(red: 0.44, green: 0.35, blue: 0.30, alpha: 1.0)
        case "fairy": return UIColor(red: 0.93, green: 0.60, blue: 0.67, alpha: 1.0)
        case "stellar": return UIColor(red: 0.40, green: 0.80, blue: 0.93, alpha: 1.0)
        default: return .systemGray
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typeLabel.text = nil
        containerView.backgroundColor = .systemGray
    }
}

