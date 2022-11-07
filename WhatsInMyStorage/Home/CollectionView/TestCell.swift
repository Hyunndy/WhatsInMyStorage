//
//  TestCell.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/08.
//

import Foundation
import UIKit

class TestCell: UICollectionViewCell {
    
    private let headerView = UIView()
    private let nameLabel = UILabel()
    private let mainImage = UIImageView()
    
    private let footerView = UIView()
    private let priceLabel = UILabel()
    private let distanceLabel = UILabel()
    
    private let margin: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    
        // HEADER
        headerView.backgroundColor = UIColor.purple
        contentView.addSubview(headerView)
        
        nameLabel.font = UIFont.systemFont(ofSize: 24)
        nameLabel.textColor = .white
        headerView.addSubview(nameLabel)

        // IMAGE
        mainImage.backgroundColor = .black
        mainImage.contentMode = .scaleAspectFill
        mainImage.clipsToBounds = true
        contentView.addSubview(mainImage)
        
        // FOOTER
        footerView.backgroundColor = UIColor.purple
        contentView.addSubview(footerView)
        
        footerView.addSubview(priceLabel)

        distanceLabel.textAlignment = .right
        footerView.addSubview(distanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(house: TestData) {
        nameLabel.text = house.name
        priceLabel.text = house.price
        distanceLabel.text = "\(house.distance) KM"
        distanceLabel.textAlignment = .right

        mainImage.download(url: house.mainImageURL)
        mainImage.contentMode = .scaleAspectFill
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        headerView.pin.top().horizontally(pin.safeArea).height(40)
        nameLabel.pin.vCenter().horizontally(margin).sizeToFit(.width)
        
        mainImage.pin.below(of: headerView).horizontally(pin.safeArea).height(300)
        
        footerView.pin.below(of: mainImage).horizontally(pin.safeArea)
        priceLabel.pin.top().horizontally().margin(margin).sizeToFit(.widthFlexible)
        distanceLabel.pin.top().after(of: priceLabel).right().margin(margin).sizeToFit(.width)
        footerView.pin.wrapContent(.vertically, padding: margin)
        
        contentView.pin.height(footerView.frame.maxY)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return contentView.frame.size
    }
}
