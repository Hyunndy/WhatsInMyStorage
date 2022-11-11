//
//  UIViewControllerDelegate.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation
import UIKit
import ReactorKit

// @유현지 pinLayout UI 세팅 프로토콜
protocol UIViewControllerDelegate {
    associatedtype mainViewType
    var mainView: mainViewType { get }
    
    func setNavigationBar()
    func setUI()
    func setLayout()
    func setRx()
}

extension UIViewControllerDelegate {
    func setNavigationBar() { }
    func setLayout() { }
    func setRx() { }
}

// @유현지 탭바 컨트롤러 프로토콜
protocol UITabBarItemControllerDelegate: UIViewController {
    var customTabBarItem: UITabBarItem { get }
    func convertToRootVC() -> UINavigationController
}

extension UITabBarItemControllerDelegate {
    func convertToRootVC() -> UINavigationController {
        let controller = UINavigationController(rootViewController: self)
//        controller.isNavigationBarHidden = true
        controller.tabBarItem = self.customTabBarItem
        
        
        return controller
    }
}
