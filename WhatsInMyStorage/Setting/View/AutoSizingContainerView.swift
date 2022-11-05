//
//  AutoSizingContainerView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/05.
//

import UIKit
import Foundation
import PinLayout

final class AutoSizingContainerView: UIView {
    
    private let imageView = UIImageView()
    private let firstTextLabel = UILabel()
    private let secondTextLabel = UILabel()
    
    private let margin: CGFloat = 10

    @Proxy(\AutoSizingContainerView.imageView.image)
    var image: UIImage? {
        didSet {
            setNeedsLayout()
        }
    }

    @Proxy(\AutoSizingContainerView.firstTextLabel.text)
    var firstText: String? {
        didSet {
            setNeedsLayout()
        }
    }

    @Proxy(\AutoSizingContainerView.secondTextLabel.text)
    var secondText: String? {
        didSet {
            setNeedsLayout()
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureView() {
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)

        self.firstTextLabel.numberOfLines = 0
        firstTextLabel.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        self.addSubview(self.firstTextLabel)
        
        self.secondTextLabel.numberOfLines = 0
        self.secondTextLabel.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        self.addSubview(self.secondTextLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        performLayout()
    }
    
    private func performLayout() {
        /*
         horizontaolly()  == view.left().right()
         */
        self.imageView.pin.top().horizontally().sizeToFit(.width).margin(margin)
        self.firstTextLabel.pin.below(of: self.imageView).horizontally().sizeToFit(.width).margin(margin)
        self.secondTextLabel.pin.below(of: firstTextLabel).horizontally().sizeToFit(.width).margin(margin)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
}
