//
//  UserSettingViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import UIKit

class UserSettingViewController: UIViewController,  UIViewControllerDelegate {
    
    func setUI() {
        //
    }
    
    func setRx() {
        //
    }
}

extension UserSettingViewController: UITabBarItemControllerDelegate {
    internal var customTabBarItem: UITabBarItem {
        get {
            return UITabBarItem(title: "설정", image: nil, tag: 1)
        }
    }
}
