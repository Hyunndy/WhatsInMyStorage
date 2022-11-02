//
//  MyStorageViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation
import UIKit
import PinLayout
import Then

class MyStorageViewController: UIViewController, UIViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setUI()
    }
    
    func setNavigationBar() {
        self.title = "재고 관리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.blue]
    }
    
    func setUI() {
        let label = UILabel().then {
            $0.backgroundColor = .purple
            $0.text = "테스트입니당"
            $0.clipsToBounds = true
            $0.textAlignment = .center
        }
        
        self.view.addSubview(label)
        label.pin.left(50.0).right(50.0).vCenter().height(50.0)
        
    }
    
    func setRx() {
        //
    }
}

extension MyStorageViewController: UITabBarItemControllerDelegate {
    internal var customTabBarItem: UITabBarItem {
        get {
            let tabBarImage = UIImage(named: "heart_filled_24")
            return UITabBarItem(title: "재고 관리", image: tabBarImage, tag: 0)
        }
    }
}
