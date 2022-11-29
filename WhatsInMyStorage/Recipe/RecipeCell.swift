//
//  RecipeCollectionViewCell.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/29.
//

import UIKit
import PinLayout

class RecipeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "RecipeCell"
    
    let mainImageView = UIImageView()
    let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .purple
        
        self.contentView.addSubview(self.mainImageView)
        _ = self.mainImageView.then {
            $0.contentMode = .scaleToFill
            $0.clipsToBounds = true
        }
        
        self.contentView.addSubview(self.nameLabel)
        _ = self.nameLabel.then {
            $0.font = .systemFont(ofSize: 15.0, weight: .bold)
            $0.textColor = .black
            $0.backgroundColor = .yellow
        }
    }
    
    func configure(recipe: Recipe) {
        self.mainImageView.image = UIImage(named: recipe.mainImageURL)
        self.nameLabel.text = recipe.name
        
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        
        self.mainImageView.pin.top().horizontally().width(150.0).height(150.0)
        self.nameLabel.pin.below(of: self.mainImageView).marginTop(10.0).horizontally().bottom().sizeToFit()
        
        self.contentView.pin.width(self.mainImageView.frame.maxX)
        self.contentView.pin.height(self.nameLabel.frame.maxY)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layout()
        return self.contentView.frame.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
