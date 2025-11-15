//
//  SectionHeaderView.swift
//  PokemonGo
//
//  Created by Boray Chen on 2025/11/15.
//

import UIKit
import SnapKit

class SectionHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SectionHeaderView"
    
    var onSeeMoreTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See more", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.systemBlue, for: .normal)
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
        addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(seeMoreButton)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(title: String, showSeeMore: Bool = true) {
        titleLabel.text = title
        seeMoreButton.isHidden = !showSeeMore
    }
    
    // MARK: - Actions
    
    @objc private func seeMoreButtonTapped() {
        onSeeMoreTapped?()
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        seeMoreButton.isHidden = false
        onSeeMoreTapped = nil
    }
}

