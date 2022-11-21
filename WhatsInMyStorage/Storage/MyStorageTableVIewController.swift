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
    
    struct Observable {
        let fetch = PublishRelay<Void>()
    }
    
    let rx = Observable()
    
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
        self.rx.fetch.accept(())
        
    }
    
    func setUI() {
        let view = MyStorageTableView()
        self.view = view
    }
    
    func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        
        self.title = "재고 관리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItems = [self.addButton, self.editButton]
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
//        self.navigationController?.navigationBar.backgroundColor = .white
        
//        let appearance = UINavigationBarAppearance()
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
//        appearance.backgroundColor = .white
//
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    
    func bind(reactor: MyStorageReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    /// Reactor에 Action 보내기
    func bindAction(reactor: MyStorageReactor) {
        
        // Fetch
        self.rx.fetch
            .map { Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
    }

    /// Reactor에서 State 받기
    func bindState(reactor: MyStorageReactor) {
        
        /// 인디케이터 .pulse(\.$myFavoriteTicket)
        reactor
            .skipInitPulse(\.$isPlayIndicator)
            .bind(onNext: { isPlayIndicator in
                
                /// 인디케이터 어케하면 예쁘게 처리할 수 있을지?ㅎㅎ 고민좀?ㅎ
                let indicator = self.mainView.indicatorView
                if isPlayIndicator == true {
                    indicator?.isHidden = false
                    indicator?.play(completion: { _ in
                        indicator?.isHidden = true
                    })
                }
            })
            .disposed(by: self.disposeBag)
        
        // Fetch
        reactor
            .skipInitPulse(\.$storageData)
            .map {
                /// 섹션이 1개 밖에 없기 때문에 map으로 던져준다.
                return MyStorageSectionData(items: $0 ?? [StorageData]())
            }
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                print("[StorageData]:: \($0)")
                
                /// Relay는 Error 이벤트로 종료되지 않기 때문에 Observable을 Relay에 bind 시키는것은 지양하는게 좋다.
                self.mainView.rx.storageSectionData.accept([$0])
                
            })
            .disposed(by: self.disposeBag)
    }
}
