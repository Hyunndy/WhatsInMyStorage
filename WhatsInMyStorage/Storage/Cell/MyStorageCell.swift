//
//  MyStorageCell.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa

class MyStorageCell: UITableViewCell {

    static let reuseIdentifier = "MyStorageCell"
    
    private let minusButton = UIButton()
    private let plusButton = UIButton()
    private let quantityLabel = UILabel()
    private let productLabel = UILabel()
    
    @Proxy(\MyStorageCell.productLabel.text)
    var product: String?
    
    @Proxy(\MyStorageCell.quantityLabel.text)
    var quantity: String?
    
    struct Observable {
        /// 양 조절
        let changeQuantity = PublishRelay<Int>()
    }
    
    var isExpandable: Bool = false
    
    let rx = Observable()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: MyStorageCell.reuseIdentifier)
        
        self.backgroundColor = .white
        self.showsReorderControl = true
        
        self.setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    private func setUI() {
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.productLabel)
        _ = self.productLabel.then {
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 20.0, weight: .regular)
            $0.textColor = UIColor.black
        }
        
        self.contentView.addSubview(self.minusButton)
        _ = self.minusButton.then {
            $0.contentMode = .center
            $0.setTitle("-", for: .normal)
            $0.setTitleColor(UIColor.wms.blue, for: .normal)
            $0.backgroundColor = UIColor.wms.gray
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15.0
            $0.isHidden = true
//            $0.layer.borderWidth = 0.1
//            $0.layer.borderColor = UIColor.black.cgColor
        }
        
        self.contentView.addSubview(self.quantityLabel)
        _ = self.quantityLabel.then {
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 20.0, weight: .regular)
            $0.textColor = UIColor.black
        }
        
        self.contentView.addSubview(self.plusButton)
        _ = self.plusButton.then {
            $0.contentMode = .center
            $0.setTitle("+", for: .normal)
            $0.setTitleColor(UIColor.wms.blue, for: .normal)
            $0.backgroundColor = UIColor.wms.gray
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15.0
            $0.isHidden = true
//            $0.layer.borderWidth = 0.1
//            $0.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func configure(storage: StorageData) {
        self.product = storage.product
        self.quantity = "\(storage.quantity)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    private func layout() {
        guard self.isExpandable == false else { return }
        
        self.productLabel.pin.vCenter().left(24.0).sizeToFit()
        self.plusButton.pin.vCenter().right(24.0).size(CGSize(width: 30.0, height: 30.0))
        self.quantityLabel.pin.before(of: self.plusButton, aligned: .center).margin(12.0).width(50.0).sizeToFit(.width)
        self.minusButton.pin.before(of: self.quantityLabel, aligned: .center).margin(12.0).size(CGSize(width: 30.0, height: 30.0))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        if self.isExpandable == true {
            return .zero
        } else {
            self.contentView.pin.width(size.width)

            layout()

            return CGSize(width: contentView.frame.width, height: 60.0)
        }
        
    }
    
    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        
        self.minusButton.isHidden = (state.rawValue == 0)
        self.plusButton.isHidden = (state.rawValue == 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/* ReactorKit */
extension MyStorageCell: View {
    
    typealias Reactor = MyStorageCellReactor
    
    func bind(reactor: MyStorageCellReactor) {
        self.minusButton.rx.tap
            .map { Reactor.Action.decrease } // Convert to Action.decrease map은 여기 써있는걸 그대로 방출시킨다.
            .bind(to: reactor.action) // Bind to reactor.action -> 여기서 Reactor에 전달된다!
            .disposed(by: self.disposeBag)
        
        self.plusButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor
            .skipInitPulse(\.$quantity)
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                self.rx.changeQuantity.accept($0)
            } )
            .disposed(by: self.disposeBag)
    }
}
