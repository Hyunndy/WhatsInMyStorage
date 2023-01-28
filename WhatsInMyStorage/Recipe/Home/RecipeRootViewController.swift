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

final class RecipeRootViewController: CustomNavigationViewController, UISettingDelegate, ReactorViewControllerDelegate {

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
    
    private var selectedSegmentIdx: Int = 0 {
        willSet {
            self.changeSelectedSegmentIdx(from: selectedSegmentIdx, to: newValue)
        }
    }
    
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
    
    
    @objc func segmentButtonSelected(_ sender: UIButton) {
        
        self.selectedSegmentIdx = sender.tag
        
        self.contentScrollViewContainer.contentOffset.x = (UIScreen.main.bounds.width * CGFloat(self.selectedSegmentIdx))
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
                $0.addTarget(self, action: #selector(segmentButtonSelected(_:)), for: .touchUpInside)
            }
            
            self.segmentButtonArray.append(button)
        }
        
        self.segmentRootContainer.flex.justifyContent(.center).paddingLeft(0.0).direction(.row).define { (flex) in
            
            for (idx, button) in self.segmentButtonArray.enumerated() {
            
                flex.addItem(button).minWidth(button.intrinsicContentSize.width + 50.0)
            }
        }
        
        self.segmentScrollViewContainer.addSubview(self.segmentRootContainer)
        // << 버튼
        
        // >> 컨텐츠
        self.view.addSubview(self.contentScrollViewContainer)
        self.contentScrollViewContainer.backgroundColor = .green
        self.contentScrollViewContainer.isPagingEnabled = true
        self.contentScrollViewContainer.delegate = self
        
        for menu in self.segmentMenuArray {
            let contentViewController = RecipeChildViewController(sortedBy: menu)
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
        
        // 검색창
        self.searchBar.rx.text
            .skip(1)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    func bindState(reactor: RecipeRootReactor) { }
    
    func bind(reactor: RecipeRootReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    private func changeSelectedSegmentIdx(from idx: Int, to idx2: Int) {
        self.segmentButtonArray[idx].removeUnderline(backTo: UIColor.wms.deepGray)
        self.segmentButtonArray[idx2].setUnderline()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.view.endEditing(true)
    }
}

extension RecipeRootViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 스크롤 뷰 오프셋
        let contentOffset = scrollView.contentOffset.x
        // 스크린 사이즈
        let screenSize = UIScreen.main.bounds.size.width
        // 현재 오프셋 인덱스
        let currentScrollIdx = Int(contentOffset / screenSize)
        
        self.selectedSegmentIdx = currentScrollIdx
    }
}
