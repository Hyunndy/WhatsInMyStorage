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

class RecipeRootViewController: CustomNavigationViewController, ReactorViewControllerDelegate, UISettingDelegate {
    
    typealias Reactor = RecipeReactor
    var disposeBag = DisposeBag()
    
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
                $0.setTitleColor(.black, for: .normal)
            }
            
            self.segmentButtonArray.append(button)
        }
        
        self.segmentRootContainer.flex.justifyContent(.center).paddingLeft(20.0).direction(.row).define { (flex) in
            
            for (idx, button) in self.segmentButtonArray.enumerated() {
                
                let leftMargin = (idx == 0) ? 0.0 : 50.0
                
                flex.addItem(button).maxWidth(50.0).marginLeft(leftMargin)
            }
        }
        
        self.segmentScrollViewContainer.addSubview(self.segmentRootContainer)
        // << 버튼
        
        
        // >> 
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
    }
    
    func bindAction(reactor: RecipeReactor) {
        
    }
    
    func bindState(reactor: RecipeReactor) {
        
    }
    
    func bind(reactor: RecipeReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setLayout()
    }
}
