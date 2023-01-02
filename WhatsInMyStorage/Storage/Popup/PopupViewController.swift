//
//  StorageAddPopupViewController.swift
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
    
    /// 섹션 라벨 + 텍스트필드
    class PopupSectionItem: UIView {
        
        @Proxy(\PopupSectionItem.label.text)
        var title: String?
        
        @Proxy(\PopupSectionItem.textField.text)
        var item: String?
        
        @Proxy(\PopupSectionItem.textField.placeholder)
        var placeholder: String?
        
        var isEditing: Bool {
            return self.textField.isEditing
        }
        
        private lazy var label: UILabel = {
            return UILabel().then {
                $0.font = .boldSystemFont(ofSize: 17.0)
                $0.textColor = UIColor.wms.green
            }
        }()
        
        private lazy var textField: UITextField = {
            return UITextField().then {
                $0.font = .boldSystemFont(ofSize: 15.0)
                $0.textColor = UIColor.black
                $0.layer.borderColor = UIColor.wms.green.cgColor
                $0.layer.borderWidth = 1.0
                $0.layer.cornerRadius = 4.0
                $0.clipsToBounds = true
                $0.addLeftPadding(padding: 5.0)
            }
        }()
        
        init() {
            super.init(frame: .zero)
            
            self.addSubview(self.label)
            self.addSubview(self.textField)
        }
        
        convenience init(title: String? = nil, placeholder: String? = nil) {
            self.init()
            
            self.title = title
            self.placeholder = placeholder
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.label.pin.top().horizontally(10.0).sizeToFit(.width)
            self.textField.pin.below(of: self.label).marginTop(5.0).bottom().horizontally(10.0).height(30.0)
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: self.label.frame.maxX, height: self.label.frame.maxY + 5.0 + 30.0)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    /// 제목
    private let titleLabel: UILabel = {
        return UILabel().then {
            $0.text = "재고 추가"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
        }
    }()
    
    let contentView = UIView()
    lazy var confirmButton: UIButton = {
        return UIButton().then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
            $0.backgroundColor = UIColor.wms.green
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 4.0
        }
    }()
    
    /// 종류
    lazy var kindsSection: PopupSectionItem = {
        return PopupSectionItem(title: "종류", placeholder: "종류를 입력하세요.")
    }()
    /// 제품명
    let productNameSection: PopupSectionItem = {
        return PopupSectionItem(title: "제품명", placeholder: "제품명을 입력하세요.")
    }()
    /// 갯수
    let quantitySection: PopupSectionItem = {
        return PopupSectionItem(title: "갯수", placeholder: "갯수를 입력하세요.")
    }()
    
    var keyBoardHeight: CGFloat = 0.0
    
    /// 키보드 올라와있는지 여부
    var isEditing: Bool {
        return (self.kindsSection.isEditing || self.productNameSection.isEditing || self.quantitySection.isEditing)
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
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.kindsSection)
        self.contentView.addSubview(self.productNameSection)
        self.contentView.addSubview(self.quantitySection)
        self.contentView.addSubview(self.confirmButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.keyBoardHeight > 0.0 {
            self.contentView.pin.bottomCenter(self.keyBoardHeight).width(70%).height(50%)
        } else {
            self.contentView.pin.bottomCenter().marginBottom(35%).width(70%).height(50%)
        }
        
        self.titleLabel.pin.top(15.0).horizontally().sizeToFit(.width)
        self.kindsSection.pin.below(of: self.titleLabel).marginTop(10.0).horizontally().sizeToFit(.width)
        self.productNameSection.pin.below(of: self.kindsSection).marginTop(10.0).horizontally().sizeToFit(.width)
        self.quantitySection.pin.below(of: self.productNameSection).marginTop(10.0).horizontally().sizeToFit(.width)
        
        self.confirmButton.pin.bottom(15.0).horizontally(10.0).sizeToFit(.width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class StorageAddPopupViewController: UIViewController, UIViewControllerDelegate {
    
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
    
    func setUI() {
        self.view = popupView()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
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
                    guard let kinds = owner.mainView.kindsSection.item, let product = owner.mainView.productNameSection.item, let quantityString = owner.mainView.quantitySection.item, let quantity = Int(quantityString) else { return }
                    
                    let item = StorageData(product: product, quantity: quantity)
                    owner.rx.addedStorageData.accept(MyStorageSectionData(header: kinds, items: [item]))
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
        
        if self.mainView.isEditing {
            self.mainView.endEditing(true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
