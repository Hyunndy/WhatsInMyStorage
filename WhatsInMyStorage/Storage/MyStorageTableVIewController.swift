//
//  MyStorageTableVIewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import ReactorKit
import RxCocoa
import RxSwift

/*
 
 재고 관리 UITableView
 
 */
class MyStorageTableViewController: UIViewController, ReactorViewControllerDelegate {
    
    typealias Reactor = MyStorageReactor
    
    typealias mainViewType = MyStorageTableView
    var mainView: MyStorageTableView {
        return self.view as! MyStorageTableView
    }
    
    var disposeBag = DisposeBag()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(navigationBarButtonTapped(_:)))
        button.tag = 0
        return button
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigationBarButtonTapped(_:)))
        button.tag = 1
        return button
    }()
    
    @objc func navigationBarButtonTapped(_ sender: UIBarButtonItem) {
        
        switch sender.tag {
        case 0:
            self.mainView.tableView.setEditing(!self.mainView.tableView.isEditing, animated: true)
        case 1:
            print("오옹")
        default:
            return
        }
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.mainView.configure(storage: [StorageData(product: "양파", quantity: 2), StorageData(product: "가공육", quantity: 2)])
    }
    
    func setUI() {
        let view = MyStorageTableView(reactor: self.reactor)
        self.view = view
    }
    
    func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        
        
        self.title = "재고 관리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationItem.leftBarButtonItem = self.editButton
        self.navigationItem.rightBarButtonItem = self.addButton
    }
    
    
    func bind(reactor: MyStorageReactor) {
        self.bindAction()
        self.bindState()
    }
    
    func bindAction() {
        
    }
    
    func bindState() {
        
    }
}
