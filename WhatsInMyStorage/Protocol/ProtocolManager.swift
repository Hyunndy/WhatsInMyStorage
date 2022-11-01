//
//  UIViewControllerDelegate.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation
import UIKit

// @유현지 UI 세팅 프로토콜
protocol UIViewControllerDelegate {
    func setUI()
    func setRx()
}

// @유현지 탭바 컨트롤러 프로토콜
protocol UITabBarItemControllerDelegate: UIViewController {
    var customTabBarItem: UITabBarItem { get }
    func convertToRootVC() -> UINavigationController
}

extension UITabBarItemControllerDelegate {
    func convertToRootVC() -> UINavigationController {
        let controller = UINavigationController(rootViewController: self)
        controller.tabBarItem = self.customTabBarItem
        
        return controller
    }
}
