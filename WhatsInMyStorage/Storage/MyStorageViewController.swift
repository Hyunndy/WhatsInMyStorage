//
//  MyStorageViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation
import UIKit

class MyStorageViewController: UIViewController, UIViewControllerDelegate {

    func setUI() {
        //
    }
    
    func setRx() {
        //
    }
}

extension MyStorageViewController: UITabBarItemControllerDelegate {
    internal var customTabBarItem: UITabBarItem {
        get {
            return UITabBarItem(title: "재고 관리", image: nil, tag: 0)
        }
    }
}
