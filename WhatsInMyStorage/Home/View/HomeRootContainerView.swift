//
//  HomeRootContainerView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/06.
//

import Foundation
import UIKit
import PinLayout
import RxSwift
import RxCocoa

final class HomeRootContainerView: UIView {
    
    private let scrollView = UIScrollView()
    let contentView = HomeContentView()
    
    struct Observable {
        var tapStorageManage: ControlEvent<Void>?
        var tapScheduleManage: ControlEvent<Void>?
    }
    
    var rx = Observable()
    
    init() {
        super.init(frame: .zero)
        
        self.setUI()
        self.setRx()
    }
    
    private func setUI() {
        self.addSubview(self.scrollView)
        _ = self.scrollView.then {
            $0.contentInsetAdjustmentBehavior = .never
            $0.alwaysBounceVertical = true
        }
        
        self.scrollView.addSubview(self.contentView)
    }
    
    private func setRx() {
        self.rx.tapStorageManage = self.contentView.storageManageButton.rx.tap
        self.rx.tapScheduleManage = self.contentView.scheduleButton.rx.tap
        
        
    }
    
    //@유현지 VC에서 View를 업데이트할 때 호출. 업데이트 쳐준 후 setNeedsLayout() 필요
    func updateHomeInfo(storeName name: String?) {
        
        self.contentView.storeName = name
        
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.performLayout()
        self.didPerformLayout()
    }
    
    private func performLayout() {
        self.scrollView.pin.all()
        self.contentView.pin.top().horizontally().sizeToFit(.width)
    }
    
    private func didPerformLayout() {
        scrollView.contentSize = CGSize(width: bounds.width, height: contentView.frame.maxY)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
