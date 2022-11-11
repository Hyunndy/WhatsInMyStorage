//
//  MyStorageTableVIewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import ReactorKit

/*
 
 재고 관리 UITableView
 
 */
class MyStorageTableViewController: UIViewController, UIViewControllerDelegate {
    
    typealias mainViewType = MyStorageTableView
    var mainView: MyStorageTableView {
        return self.view as! MyStorageTableView
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainView.configure(storage: [StorageData(name: "아아", quantity: 2), StorageData(name: "아아", quantity: 2)])
    }
    
    func setUI() {
        self.view = MyStorageTableView()
    }
}
