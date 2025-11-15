//
//  PokemonCell.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import UIKit
import SnapKit
import Kingfisher

class PokemonCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "PokemonCell"
    
    private var isFavorite = false
    private var onFavoriteToggle: ((Bool) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let typesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let pokeballImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.circle.fill")
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        return button
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
        
        containerView.addSubview(pokemonImageView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(typesStackView)
        containerView.addSubview(pokeballImageView)
        containerView.addSubview(rightImageView)
        containerView.addSubview(favoriteButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        pokemonImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalTo(pokemonImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel)
            make.top.equalTo(numberLabel.snp.bottom).offset(4)
        }
        
        typesStackView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        pokeballImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(60)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(with pokemon: PokemonSummary, isFavorite: Bool = false, onFavoriteToggle: ((Bool) -> Void)? = nil) {
        numberLabel.text = "#\(pokemon.id)"
        nameLabel.text = pokemon.name.uppercased()
        
        self.isFavorite = isFavorite
        self.onFavoriteToggle = onFavoriteToggle
        favoriteButton.isSelected = isFavorite
        
        // Load pokemon image
        if let imageURLString = pokemon.imageURLString, let url = URL(string: imageURLString) {
            pokemonImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            pokemonImageView.image = UIImage(systemName: "photo")
        }
        
        // Configure types
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for typeName in pokemon.typeNames {
            let typeLabel = createTypeLabel(for: typeName)
            typesStackView.addArrangedSubview(typeLabel)
        }
        
        // Set background color based on primary type
        if let primaryType = pokemon.typeNames.first {
            containerView.backgroundColor = getTypeColor(for: primaryType).withAlphaComponent(0.15)
        }
    }
    
    private func createTypeLabel(for type: String) -> UILabel {
        let label = UILabel()
        label.text = type.capitalized
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = getTypeColor(for: type)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        
        label.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(60)
        }
        
        return label
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
        default: return .systemGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func favoriteButtonTapped() {
        isFavorite.toggle()
        favoriteButton.isSelected = isFavorite
        onFavoriteToggle?(isFavorite)
        
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pokemonImageView.kf.cancelDownloadTask()
        pokemonImageView.image = nil
        rightImageView.image = nil
        numberLabel.text = nil
        nameLabel.text = nil
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        containerView.backgroundColor = .systemBackground
        isFavorite = false
        favoriteButton.isSelected = false
        onFavoriteToggle = nil
    }
}
