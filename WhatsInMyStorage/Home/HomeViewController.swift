//
//  HomeViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/06.
//

import Foundation
import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa
import ReactorKit

/*
 매장 이미지가 보이는 CollectionView
 내 매장 정보 나오는 UIView
 
 재고 목록 가기
 레시피 가기
 이번 달 재고 예산비 기록(?)
 */

final class HomeRootViewController: UIViewController, UIViewControllerDelegate {
    typealias mainViewType = HomeRootContainerView
    
    var mainView: mainViewType {
        return self.view as! HomeRootContainerView
    }
    
    var disposeBag = DisposeBag()
    
    let fetch = PublishRelay<Void>()
    
    override func loadView() {
        super.loadView()
        
        self.view = HomeRootContainerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setUI()
        self.setRx()
        
        self.fetch.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func setNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setUI() {
        //
    }
    
    func setLayout() {
        //
    }
    
    func setRx() {
        
        self.mainView.rx.tapStorageManage?
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                let myStorageViewController = MyStorageTableViewController()
                myStorageViewController.reactor = MyStorageReactor()
                
                self.navigationController?.show(myStorageViewController, sender: nil)
            })
            .disposed(by: self.disposeBag)
    }
}

extension HomeRootViewController: UITabBarItemControllerDelegate {
    internal var customTabBarItem: UITabBarItem {
        get {
            let tabBarImage = UIImage(named: "heart_filled_24")
            return UITabBarItem(title: "홈", image: tabBarImage, tag: 2)
        }
    }
}

extension HomeRootViewController: View {
    
    func bind(reactor: HomeReactor) {
        
        self.fetch
            .map { Reactor.Action.homeInfo }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        
        reactor.state
            .map { $0.homeInfo }
            .bind(onNext: { title in
                DispatchQueue.main.async {
                    self.mainView.updateHomeInfo(storeName: title)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    typealias Reactor = HomeReactor
    
    
    
}
