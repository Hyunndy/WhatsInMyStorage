//
//  RecipeCollectionViewCell.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import UIKit
import Then
import PinLayout
import FlexLayout

class RecipeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RecipeCollectionViewCell"
    
//    @Proxy(\StorageCell.productLabel.text)
    @Proxy(\RecipeCollectionViewCell.nameLabel.text)
    var name: String?
    
    @Proxy(\RecipeCollectionViewCell.priceLabel.text)
    var price: String?
    
    private let rootContainerView = UIView()
    
    private lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.font = .boldSystemFont(ofSize: 10.0)
            $0.textColor = .black
        }
    }()
    
    private lazy var priceLabel: UILabel = {
        return UILabel().then {
            $0.font = .boldSystemFont(ofSize: 10.0)
            $0.textColor = UIColor.wms.green
        }
    }()
    
    private lazy var imageView: UIImageView = {
        return UIImageView(frame: .zero).then {
            $0.contentMode = .scaleToFill
        }
    }()
    
    func configure(name: String?, price: Int?, image: String?) {
        self.name = name
        self.price = String(price ?? 0)
        self.imageView.image = UIImage(named: image ?? "")
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.rootContainerView.flex.direction(.column).define { flex in
            
            flex.addItem(self.imageView).grow(1).marginHorizontal(0.0)
            flex.addItem(self.nameLabel).marginTop(10.0)
            flex.addItem(self.priceLabel).marginTop(10.0)
        }
        
        
        self.contentView.addSubview(self.rootContainerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rootContainerView.pin.all()
        
        self.rootContainerView.flex.layout(mode: .adjustHeight)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
