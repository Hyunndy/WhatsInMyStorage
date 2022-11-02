//
//  UserSettingViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import UIKit

class UserSettingViewController: UIViewController,  UIViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setUI()
    }
    
    func setNavigationBar() {
        self.title = "설정"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.blue]
    }
    
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
            let tabBarImage = UIImage(named: "heart_filled_24")
            let tabBar = UITabBarItem(title: "설정", image: tabBarImage, tag: 1)
            return tabBar
        }
    }
}
