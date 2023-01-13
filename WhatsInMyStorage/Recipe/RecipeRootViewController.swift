//
//  RecipeRootViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import UIKit
import ReactorKit
import RxSwift
import FlexLayout
import Then

class RecipeRootViewController: CustomNavigationViewController, UISettingDelegate, ReactorViewControllerDelegate {

    var disposeBag = DisposeBag()
    
    typealias Reactor = RecipeRootReactor
    
    lazy var searchBar: UISearchBar = {
         return UISearchBar().then {
             $0.placeholder = "검색어를 입력해주세요."
             $0.searchBarStyle = .minimal
             $0.searchTextField.layer.borderColor = UIColor.wms.green.cgColor
             $0.searchTextField.layer.cornerRadius = 10
             $0.searchTextField.layer.borderWidth = 1
             $0.searchTextField.largeContentImage?.withTintColor(UIColor.wms.green) // 왼쪽 돋보기 모양 커스텀
             $0.searchTextField.borderStyle = .none // 기본으로 있는 회색배경 없애줌
             $0.searchTextField.leftView?.tintColor = UIColor.wms.green
             $0.searchTextField.textColor = .black
        }
    }()
    
    // >> 버튼
    let segmentScrollViewContainer = UIScrollView()
    let segmentRootContainer = UIView()
    let segmentMenuArray = ["All", "음료", "디저트", "식사", "옴뇸뇸"]
    var segmentButtonArray = [UIButton]()
    // <<
    
    // >> 레시피 뷰
    let contentScrollViewContainer = UIScrollView()
    let contentRootContainer = UIView()
    // <<
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNavigationBar() {
        self.title = "레시피"
    }
    
    func setUI() {
        self.view.addSubview(self.searchBar)
        
        // >> 버튼
        self.view.addSubview(self.segmentScrollViewContainer)
        
        for (idx, menu) in segmentMenuArray.enumerated() {
            let button = UIButton().then {
                $0.setTitle(menu, for: .normal)
                $0.tag = idx
                $0.setTitleColor(UIColor.wms.deepGray, for: .normal)
                $0.titleLabel?.font = .boldSystemFont(ofSize: 15.0)
            }
            
            self.segmentButtonArray.append(button)
        }
        
        self.segmentRootContainer.flex.justifyContent(.center).paddingLeft(20.0).direction(.row).define { (flex) in
            
            for (idx, button) in self.segmentButtonArray.enumerated() {
                
                let leftMargin = (idx == 0) ? 0.0 : 50.0
                
                flex.addItem(button).minWidth(20.0).marginLeft(leftMargin)
            }
        }
        
        self.segmentScrollViewContainer.addSubview(self.segmentRootContainer)
        // << 버튼
        
        
        // >> 컨텐츠
        self.view.addSubview(self.contentScrollViewContainer)
        self.contentScrollViewContainer.backgroundColor = .green
        self.contentScrollViewContainer.isPagingEnabled = true
        
        for menu in self.segmentMenuArray {
            let contentViewController = RecipeChildViewController(sortedBy: menu)
//            contentViewController.reactor = RecipeReactor(recipeRelay: self.reactor!.recipeArray)
            contentViewController.reactor = RecipeReactor(service: self.reactor!.service)
            
            self.addChild(contentViewController)
            self.contentRootContainer.flex.direction(.row).define { (flex) in
                flex.addItem(contentViewController.view).width(UIScreen.main.bounds.width)
            }
            contentViewController.didMove(toParent: self)
        }
        
        self.contentScrollViewContainer.addSubview(self.contentRootContainer)
        // <<
    }
    
    func setLayout() {
        self.searchBar.pin.below(of: self.navigationBarView).horizontally(20.0).sizeToFit(.width)
        
        // >> 버튼
        // 1) Layout the scrollView & FlexRootContainer using PinLayout
        self.segmentScrollViewContainer.pin.below(of: self.searchBar).marginTop(10.0).horizontally().height(50.0)
        self.segmentRootContainer.pin.all()
        
        // 2) Let the flexbox Container layout itself and adjust width or height
        self.segmentRootContainer.flex.layout(mode: .adjustWidth)
        
        // 3) Adjust the scrollView contentSize
        self.segmentScrollViewContainer.contentSize = self.segmentRootContainer.frame.size
        // <<
        
        // >> 컨텐츠
        // 1) Layout the scrollView & FlexRootContainer using PinLayout
        self.contentScrollViewContainer.pin.below(of: self.segmentScrollViewContainer).marginTop(10.0).horizontally().bottom()
        self.contentRootContainer.pin.all()
        
        // 2) Let the flexbox Container layout itself and adjust width or height
        self.contentRootContainer.flex.layout(mode: .adjustWidth)
        
        // 3) Adjust the scrollView contentSize
        self.contentScrollViewContainer.contentSize = self.contentRootContainer.frame.size
        // <<
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
        self.segmentButtonArray[0].setUnderline()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setLayout()
    }
    
    
    func bindAction(reactor: RecipeRootReactor) {
        
        self.rx.viewDidLoad
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        
    }
    
    func bindState(reactor: RecipeRootReactor) {
        
    }
    
    func bind(reactor: RecipeRootReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
}
