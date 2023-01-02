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
import RxKeyboard

final class popupView: UIView {
    
    let contentView = UIView()
    let titleLabel = UILabel()
    
    let sectionLabel = UILabel()
    let sectionTextField = UITextField()
    
    let infoLabel = UILabel()
    let productTextField = UITextField()
    let info2Label = UILabel()
    let quantityTextField = UITextField()
    let confirmButton = UIButton()
    
    var keyBoardHeight: CGFloat = 0.0
    
    /// 섹션 라벨 + 텍스트필드
    class PopupSectionItem: UIView {
        
    }
    
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
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
        }
        
        self.contentView.addSubview(sectionLabel)
        _ = sectionLabel.then {
            $0.text = "종류"
            $0.font = .boldSystemFont(ofSize: 17.0)
            $0.textColor = UIColor.wms.green
        }
        
        self.contentView.addSubview(sectionTextField)
        _ = sectionTextField.then {
            $0.font = .boldSystemFont(ofSize: 15.0)
            $0.textColor = UIColor.black
            $0.placeholder = "섹션을 입력하세요."
            $0.layer.borderColor = UIColor.wms.green.cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.addLeftPadding(padding: 5.0)
        }
        
        self.contentView.addSubview(infoLabel)
        _ = infoLabel.then {
            $0.text = "제품명"
            $0.font = .boldSystemFont(ofSize: 17.0)
            $0.textColor = UIColor.wms.green
        }
        
        self.contentView.addSubview(self.productTextField)
        _ = self.productTextField.then {
            $0.font = .boldSystemFont(ofSize: 15.0)
            $0.textColor = UIColor.black
            $0.placeholder = "항목을 입력하세요."
            $0.layer.borderColor = UIColor.wms.green.cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.addLeftPadding(padding: 5.0)
        }
        
        self.contentView.addSubview(info2Label)
        _ = info2Label.then {
            $0.text = "갯수"
            $0.font = .boldSystemFont(ofSize: 17.0)
            $0.textColor = UIColor.wms.green
        }
    
        self.contentView.addSubview(self.quantityTextField)
        _ = self.quantityTextField.then {
            $0.font = .boldSystemFont(ofSize: 15.0)
            $0.textColor = UIColor.black
            $0.layer.borderColor = UIColor.wms.green.cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4.0
            $0.clipsToBounds = true
            $0.addLeftPadding(padding: 5.0)
            $0.placeholder = "수량을 입력하세요."
        }
        
        self.contentView.addSubview(self.confirmButton)
        _ = self.confirmButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
            $0.backgroundColor = UIColor.wms.green
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 4.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.keyBoardHeight > 0.0 {
            self.contentView.pin.bottomCenter(self.keyBoardHeight).width(70%).height(50%)
        } else {
            self.contentView.pin.bottomCenter().marginBottom(35%).width(70%).height(50%)
        }
        
        self.titleLabel.pin.top(15.0).horizontally().sizeToFit(.width)
        self.sectionLabel.pin.below(of: self.titleLabel).marginTop(10.0).horizontally(10.0).sizeToFit()
        self.sectionTextField.pin.below(of: self.sectionLabel, aligned: .left).marginTop(5.0).horizontally(10.0).height(30.0)

        self.infoLabel.pin.below(of: self.sectionTextField).marginTop(10.0).horizontally(10.0).sizeToFit(.width)
        self.productTextField.pin.below(of: self.infoLabel, aligned: .left).marginTop(5.0).horizontally(10.0).height(30.0)
        
        self.info2Label.pin.below(of: self.productTextField, aligned: .left).marginTop(10.0).horizontally(10.0).sizeToFit(.width)
        self.quantityTextField.pin.below(of: self.info2Label, aligned: .left).marginTop(5.0).horizontally(10.0).height(30.0)
        self.confirmButton.pin.bottom(15.0).horizontally(10.0).sizeToFit(.width)
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
        let addedStorageData = PublishRelay<MyStorageSectionData>()
    }
    
    let rx = Observable()
    
    static func show(target: UIViewController) {
        let popupViewController = PopupViewController()
        
        target.navigationController?.present(popupViewController, animated: true)
    }
    
    func setUI() {
        self.view = popupView()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    func setLayout() {
        self.mainView.pin.all()
    }
    
    func setRx() {
        self.mainView.confirmButton.rx.tap
            .subscribe(with: self,
                       onNext: { (owner, _) in
                
                owner.dismiss(animated: true, completion: {
                    guard let header = owner.mainView.sectionTextField.text, let product = owner.mainView.productTextField.text, let quantityString = owner.mainView.quantityTextField.text, let quantity = Int(quantityString) else { return }
                    
                    let item = StorageData(product: product, quantity: quantity)
                    owner.rx.addedStorageData.accept(MyStorageSectionData(header: header, items: [item]))
                })
            })
            .disposed(by: self.disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self,
                   onNext: { (owner, keyboardHeight) in
                
                owner.mainView.keyBoardHeight = keyboardHeight
                owner.mainView.layoutSubviews()
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
        
        if self.mainView.sectionTextField.isEditing || self.mainView.productTextField.isEditing || self.mainView.quantityTextField.isEditing {
            self.mainView.endEditing(true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
