//
//  AutoSizingView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/05.
//

import Foundation
import PinLayout
import UIKit

final class AutoSizingView: UIView {
    private let scrollView = UIScrollView()
    private let containerView = AutoSizingContainerView()

    private let margin: CGFloat = 30

    init() {
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        backgroundColor = .white

        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)
        
        containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        scrollView.addSubview(containerView)
    }

    func updateImage(_ image: UIImage?) {
        containerView.image = image
        setNeedsLayout()
    }

    func updateTexts(firstText: String?, secondText: String?) {
        containerView.firstText = firstText
        containerView.secondText = secondText
        setNeedsLayout()
    }
    
    /*
     layoutSubviews를 호출할 때 마다
     1. 레이아웃 자체를 다시 잡는다.
     2. contentSize를 잡는다.
    
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
        didPerformLayout()
    }
    
    private func performLayout() {
        scrollView.pin.all()
        containerView.pin.top(margin).horizontally(margin).sizeToFit(.width)
    }

    private func didPerformLayout() {
        scrollView.contentSize = CGSize(width: bounds.width, height: containerView.frame.maxY + margin)
    }
    
}
