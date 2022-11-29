//
//  PopupViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/26.
//

import UIKit
import PinLayout
import RxSwift
import RxCocoa

class popupView: UIView {
    
    let contentView = UIView()
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let productTextField = UITextField()
    let info2Label = UILabel()
    let quantityTextField = UITextField()
    let confirmButton = UIButton()
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white.withAlphaComponent(0.0)
        
        self.addSubview(self.contentView)
        _ = self.contentView.then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10.0
            $0.backgroundColor = .white
        }
        
        self.contentView.addSubview(titleLabel)
        _ = titleLabel.then {
            $0.text = "재고 추가"
            $0.font = .boldSystemFont(ofSize: 24.0)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
        }
        
        self.contentView.addSubview(infoLabel)
        _ = infoLabel.then {
            $0.text = "Product Name"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
        }
        
        self.contentView.addSubview(self.productTextField)
        _ = self.productTextField.then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.placeholder = "항목을 입력하세요."
            $0.layer.borderColor = UIColor.wms.gray.cgColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
        }
        
        self.contentView.addSubview(info2Label)
        _ = info2Label.then {
            $0.text = "Quantity"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
        }
    
        self.contentView.addSubview(self.quantityTextField)
        _ = self.quantityTextField.then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            
            $0.placeholder = "항목을 입력하세요."
            $0.layer.borderColor = UIColor.wms.gray.cgColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
        }
        
        self.contentView.addSubview(self.confirmButton)
        _ = self.confirmButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.pin.center().marginBottom(safeAreaInsets.top).width(70%).height(50%)
        
        self.titleLabel.pin.top(10.0).horizontally().sizeToFit(.width)
        self.infoLabel.pin.below(of: self.titleLabel).marginTop(30.0).horizontally(10.0).sizeToFit()
        self.productTextField.pin.below(of: self.infoLabel, aligned: .left).marginTop(10.0).horizontally(10.0).height(40.0)
        self.info2Label.pin.below(of: self.productTextField, aligned: .left).marginTop(10.0).horizontally().sizeToFit()
        self.quantityTextField.pin.below(of: self.info2Label, aligned: .left).marginTop(10.0).horizontally(10.0).height(40.0)
        self.confirmButton.pin.bottomCenter(10.0).horizontally(10.0).size(20%)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopupViewController: UIViewController, UIViewControllerDelegate {
    
    typealias mainViewType = popupView
    var mainView: popupView {
        get {
            return self.view as! popupView
        }
    }
    
    let disposeBag = DisposeBag()
    
    struct Observable {
        let addedStorageData = PublishRelay<StorageData>()
    }
    
    let rx = Observable()
    
    
    func setUI() {
        self.view = popupView()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    func setLayout() {
        self.mainView.pin.all()//.center().width(70%).height(50%)
    }
    
    func setRx() {
        self.mainView.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.dismiss(animated: true, completion: { [weak self] in
                    guard let self, let product = self.mainView.productTextField.text, let quantityString = self.mainView.quantityTextField.text, let quantity = Int(quantityString) else { return }
                    
                    self.rx.addedStorageData.accept(StorageData(product: product, quantity: quantity))
                })
            })
            .disposed(by: self.disposeBag)
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRx()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first, self.mainView.bounds.contains(touch.location(in: self.mainView.contentView)) == false  else { return }
        
        if self.mainView.productTextField.isEditing || self.mainView.quantityTextField.isEditing {
            self.mainView.endEditing(true)
        } else {
            self.dismiss(animated: true)
        }
        
    }
}
