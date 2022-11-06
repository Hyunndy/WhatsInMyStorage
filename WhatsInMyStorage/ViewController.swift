//
//  ViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/10/31.
//

import UIKit

/*
 메인화면
 
 1. 재고관리 메인 탭
 2. 설정 탭
 */

final class MainTabBarController: UITabBarController {
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        self.tabBar.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRootViewControllers()
    }
    
    private func setRootViewControllers() {
        
        let homeRootViewController = HomeRootViewController()
        homeRootViewController.reactor = HomeReactor()
        
        let originalVCArray: Array<UIViewController & UITabBarItemControllerDelegate> = [homeRootViewController, UserSettingViewController()]
        let rootVCArray = originalVCArray.map( { $0.convertToRootVC() })
        self.setViewControllers(rootVCArray, animated: true)
    }
}
