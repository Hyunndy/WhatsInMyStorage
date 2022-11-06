//
//  HomeContentView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/06.
//

import Foundation
import UIKit
import Then
import PinLayout
import FlexLayout

final class HomeContentView: UIView {
    
    /// 매장 명
    private let storeLabel = UILabel()
    /// 재고 관리 버튼
    let storageManageButton = UIButton()
    
    @Proxy(\HomeContentView.storeLabel.text)
    var storeName: String? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        self.setUI()
    }
    
    private func setUI() {
        
        _ = self.storeLabel.then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.textColor = UIColor.black
            $0.font = .boldSystemFont(ofSize: 16.0)
            $0.layer.cornerRadius = 4.0
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor(red: 0.922, green: 0.933, blue: 0.965, alpha: 1).cgColor
            $0.clipsToBounds = true
        }
        self.addSubview(self.storeLabel)
        
        _ = self.storageManageButton.then {
            $0.setTitle("재고 관리", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = UIColor(red: 0.984, green: 0.278, blue: 0.376, alpha: 1)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.titleLabel?.textAlignment = .center
        }
        self.addSubview(self.storageManageButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.performLayout()
    }
    
    private func performLayout() {
        self.storeLabel.pin.top().horizontally(16.0).minHeight(100.0).sizeToFit(.width)
        self.storageManageButton.pin.below(of: self.storeLabel).margin(16.0).horizontally().height(50.0).sizeToFit(.width)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
