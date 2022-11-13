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
    
    /// 매장 이미지
    private let storeImageView = UIImageView()
    /// 매장 명
    private let storeLabel = UILabel()
    /// 재고 관리 버튼
    let storageManageButton = UIButton()
    /// 스케쥴 버튼
    let scheduleButton = UIButton()
    /// 레시피 버튼
    
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
        
        self.addSubview(self.storeImageView)
        _ = self.storeImageView.then {
            $0.image = UIImage(named: "kikiStore")
            $0.contentMode = .scaleToFill
        }
        
        self.addSubview(self.storeLabel)
        _ = self.storeLabel.then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.textColor = UIColor.black
            $0.backgroundColor = .white
            $0.text = "Kiki's Delivery Service"
            $0.font = .boldSystemFont(ofSize: 16.0)
            $0.layer.cornerRadius = 4.0
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor(red: 0.922, green: 0.933, blue: 0.965, alpha: 1).cgColor
            $0.clipsToBounds = true
        }
        
        self.addSubview(self.storageManageButton)
        _ = self.storageManageButton.then {
            $0.setTitle("재고 관리", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = UIColor(red: 0.984, green: 0.278, blue: 0.376, alpha: 1)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.titleLabel?.textAlignment = .center
        }
        
        self.addSubview(self.scheduleButton)
        _ = self.scheduleButton.then {
            $0.setTitle("스케쥴 관리", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = UIColor(red: 0.984, green: 0.278, blue: 0.376, alpha: 1)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.titleLabel?.textAlignment = .center
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.performLayout()
    }
    
    private func performLayout() {
        self.storeImageView.pin.top().horizontally().height(UIScreen.main.bounds.width)
        self.storeLabel.pin.below(of: self.storeImageView).marginTop(-25.0).horizontally(24.0).height(50.0)
        
        /// FlexLayout으로 바꾸던가 해야될 것 같음
        self.storageManageButton.pin.below(of: self.storeLabel).marginTop(16.0).left(2.5%).width(45%).minHeight(100.0)
        self.scheduleButton.pin.below(of: self.storeLabel).marginTop(16.0).right(2.5%).width(45%).minHeight(100.0)
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
