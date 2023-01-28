//
//  RecipeDetailHeaderView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/18.
//

import UIKit
import PinLayout
import FlexLayout

class RecipeDetailHeaderView: UICollectionReusableView {
    
    static let identifier = "RecipeDetailHeaderView"
    
    private let contentView = UIView()
    private let flexRootContainer = UIView()
    
    lazy var imageView: UIImageView = {
       
        return UIImageView().then {
            $0.image = UIImage(named: "kikiStore")
            $0.clipsToBounds = true
            $0.contentMode = .scaleToFill
            $0.layer.cornerRadius = 5.0
        }
    }()
    
    lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.text = "이름"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = .black
        }
    }()
    
    lazy var priceLabel: UILabel = {
        return UILabel().then {
            $0.text = "가격"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = .black
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.flexRootContainer.flex.direction(.column).justifyContent(.start).define { (flex) in
            
            // Image
            flex.addItem(self.imageView).height(250.0).marginHorizontal(5%)
            
            // Info row
            flex.addItem().direction(.column).justifyContent(.spaceBetween).grow(1).define { (flex) in
                flex.addItem(self.nameLabel)
                flex.addItem(self.priceLabel).marginTop(5.0)
            }.marginTop(10.0).marginHorizontal(5%)
        }
        
        self.addSubview(self.flexRootContainer)
        
//        self.addSubview(self.imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.layout()
        return self.flexRootContainer.frame.size
//        return CGSize(width: UIScreen.main.bounds.width, height: self.imageView.frame.maxY + self.nameLabel.frame.maxY)
    }
    
    func layout() {
        
        self.flexRootContainer.pin.all().width(100%)
        self.flexRootContainer.flex.layout(mode: .adjustHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LineSeperatorFooterView: UICollectionReusableView {
    
    static let identifier = "LineSeperatorFooterView"
    
    private let lineView = UIView()
    
    override var backgroundColor: UIColor? {
        didSet {
            self.lineView.backgroundColor = backgroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.lineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.lineView.pin.all().height(5.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
