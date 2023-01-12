//
//  RootViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/03.
//

import UIKit
import PinLayout
import Then

/*
 커스텀 네비바를 가진 모든 뷰의 Root
 */
class CustomNavigationViewController: UIViewController {

    override var title: String? {
        didSet {
            self.titleLabel.text = title
            self.navigationBarView.layoutIfNeeded()
        }
    }
    
    let navigationBarView = UIView()
    private let titleLabel = UILabel()
    
    override func loadView() {
        self.view = UIView()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.navigationBarView)
        self.navigationBarView.backgroundColor = .white
        
        self.navigationBarView.addSubview(self.titleLabel)
        _ = self.titleLabel.then {
            $0.textAlignment = .center
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 44.0
        self.navigationBarView.pin.top(self.view.safeAreaInsets.top).horizontally().height(navigationBarHeight)
        self.titleLabel.pin.vertically().hCenter().sizeToFit(.height)
    }
}

extension CustomNavigationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController else { return false }
        
        return (navigationController.isNavigationBarHidden == true && navigationController.viewControllers.count > 1)
    }
}
