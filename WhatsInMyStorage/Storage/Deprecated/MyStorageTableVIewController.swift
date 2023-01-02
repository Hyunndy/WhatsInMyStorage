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
        /// 재고 목록 Section Data
        var storageSectionData = BehaviorRelay<[MyStorageSectionData]>(value: [MyStorageSectionData(items: [StorageData]())])
    }
    
    var currentSectionData: [MyStorageSectionData] {
        get {
            return self.rx.storageSectionData.value
        }
    }
    
    let rx = Observable()
    
    var disposeBag = DisposeBag()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        button.tag = 0
        return button
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        button.tag = 1
        return button
    }()
    
    private func openPopup() {
        
        guard let reactor = self.reactor else { return }
        
        // 액션에 연결
        let StorageAddPopupViewController = StorageAddPopupViewController()
        StorageAddPopupViewController.rx.addedStorageData
            .map { addedStorageData in
                Reactor.Action.newinsertStorage(self.currentSectionData, addedStorageData)
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.present(StorageAddPopupViewController, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.rx.fetch.accept(())
        
        // 저장하기
        self.mainView.confirmButton.rx.tap
            .map { Reactor.Action.confirm(self.currentSectionData)}
            .bind(to: self.reactor!.action)
            .disposed(by: self.disposeBag)
        
    }
    
    func setUI() {
        let view = MyStorageTableView(storageData: self.rx.storageSectionData)
        self.view = view
    }
    
    func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        
        self.title = "재고 관리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItems = [self.addButton, self.editButton]
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        
        // editing 버튼
        self.editButton.rx.tap
            .map { Reactor.Action.editing(!self.mainView.tableView.isEditing)}
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // + 버튼
        self.addButton.rx.tap
            .map { Reactor.Action.add }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }

    /// Reactor에서 State 받기
    func bindState(reactor: MyStorageReactor) {
        
        /// 인디케이터 .pulse(\.$myFavoriteTicket)
        reactor
            .pulse(\.$isPlayIndicator)
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
            .pulse(\.$storageData)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                print("[StorageData]:: \($0?[0].items)")
                
                /// Relay는 Error 이벤트로 종료되지 않기 때문에 Observable을 Relay에 bind 시키는것은 지양하는게 좋다.
                self.rx.storageSectionData.accept($0 ?? [MyStorageSectionData]())
                
            })
            .disposed(by: self.disposeBag)
        
        // Editing
        reactor
            .pulse(\.$isEditing)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.mainView.tableView.setEditing($0, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        // + 버튼
        reactor
            .pulse(\.$openPopup)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.openPopup()
            })
            .disposed(by: self.disposeBag)
        
        // 저장하기
        reactor
            .pulse(\.$confirm)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}
