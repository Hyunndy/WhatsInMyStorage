//
//  MyStorageViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation
import UIKit
import PinLayout
import FlexLayout
import RxSwift
import ReactorKit
import RxCocoa
import Then

// (-) 버튼 (라벨) (+) 버튼
class MyStorageViewController: UIViewController, UIViewControllerDelegate {
    
    typealias mainViewType = MyStorageRootContainerView
    var mainView: MyStorageRootContainerView {
        get {
            return self.view as! MyStorageRootContainerView
        }
    }
    
    // 1) flexBox 가장 바깥쪽 Container를 만들고 addSubview 한다.
    let rootFlexContainer = UIView()
    
    let minusButton = UIButton()
    let plusButton = UIButton()
    let countLabel = UILabel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setUI()
    }
    
    func setLayout() {
        
    }
    
    func setNavigationBar() {
        self.title = "재고 관리"
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    
    func setUI() {
        
        /*
         MARK: PINt 메서드 정의 순서
         view.pin. [EDGE | ANCHOR | RELATIVE]. [WIDTH | HEIGHT | SIZE]. [pinEdges ()]. ​​[MARGINS]. [sizeToFit ()]
         */
        _ = self.minusButton.then {
            $0.setImage(UIImage(named: "heart_filled_24"), for: .normal)
        }//.pin.size(20)
        
        _ = self.countLabel.then {
            $0.text = "재고관리"
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 15.0, weight: .bold)
            $0.textColor = UIColor.black
        }//.pin.width(100.0).height(100.0)
        
        _ = self.plusButton.then {
            $0.backgroundColor = .purple
            $0.setImage(UIImage(named: "heart_filled_24"), for: .normal)
        }//.pin.size(CGSize(width: 100.0, height: 100.0))
        
        // 2) Container 구조를 정의한다. define closure안에서 내가 만들 flexbox들을 구조화 하면 된다.
        self.view.addSubview(self.rootFlexContainer)
        
        /*
         MARK: Define할 때 설정할 수 있는 값들
            direction: axis 설정
            padding: container와 subview 사이의 padding 값
            backgroundColor
            flex.addItem(item).grow(우선순위): flexItem이 성장(grow)하는 기능을 정의한다. 우선순위를 정해서 어떤 view가 크기를 더 많이 차지할지 결정하게한다!
         
            justifyContent: main-axis(메인정렬축)을 따라 정렬을 정의하는 프로퍼티
            alignmentItem: mainx-axis의 cross-axis를 따라 정렬하는 프로퍼티
        
         
            근데 subView들의 크기를 밖에서 pin으로 지정해주고 들어가면 안먹는다.
            무조건 flexBox의 define에서 먹여야 먹는다.. 왜이러지?
         */
        
        self.rootFlexContainer.flex
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .backgroundColor(.yellow)
            .define { (flex) in
            
                flex.addItem(self.minusButton).width(30%).height(30%)
                flex.addItem(self.countLabel).grow(1)
                flex.addItem(self.plusButton).width(30%).height(30%)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 3) Container를 pinLayout으로 레이아웃 해준다.
        self.rootFlexContainer.pin.all()
        // 4) Container 메서드인 layout()을 사용하여 Container의 flexBox들을 layout 시킨다.
        /*
         MARK: layout의 옵션
            - fitContainer: child는 container의 크기(width, height)내에 배치된다.
            - adjustHeight: child는 container의 width에만 맞춰지고, height은 child에 맞게 지정된다.
            - adjustWidth
         */
        self.rootFlexContainer.flex.layout()
    }
    
    func setRx() {
        //
    }
}

// ReactorKit 관련!
extension MyStorageViewController: View {
    
    typealias Reactor = MyStorageReactor
    
    // Called when the new value is assigned to 'self.reactor'
    func bind(reactor: MyStorageReactor) {
        self.setAction(reactor: reactor)
        self.setState(reactor: reactor)
    }
    
    // Event가 발생하면 Reactor에 Action을 전달!!!!
    private func setAction(reactor: MyStorageReactor) {
        
        self.minusButton.rx.tap
            .map { Reactor.Action.decrease } // Convert to Action.decrease map은 여기 써있는걸 그대로 방출시킨다.
            .bind(to: reactor.action) // Bind to reactor.action -> 여기서 Reactor에 전달된다!
            .disposed(by: self.disposeBag)
        
        self.plusButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    // State
    private func setState(reactor: MyStorageReactor) {
        
        reactor.state
            .map { $0.count } // 방출된 state struct에서 count만 뽑아낸다.
            .distinctUntilChanged()
            .map { "\($0)"}
            .bind(to: self.countLabel.rx.text) // UITextField에 바인딩 한다.
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self else { return }
                
                let alertController = UIAlertController(
                  title: nil,
                  message: message,
                  preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                  title: "OK",
                  style: .default,
                  handler: nil
                ))
                self.present(alertController, animated: true)
                
            }).disposed(by: self.disposeBag)
    }
}
