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
    
    /// @유현지 disposeBag 객체 해제해줘야하는지?
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
        
        self.productLabel.pin.vCenter().left(24.0).sizeToFit()
        self.plusButton.pin.vCenter().right(24.0).size(CGSize(width: 30.0, height: 30.0))
        self.quantityLabel.pin.before(of: self.plusButton, aligned: .center).margin(12.0).width(50.0).sizeToFit(.width)
        self.minusButton.pin.before(of: self.quantityLabel, aligned: .center).margin(12.0).size(CGSize(width: 30.0, height: 30.0))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        self.contentView.pin.width(size.width)

        layout()

        return CGSize(width: contentView.frame.width, height: 60.0)
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
            .map { "\($0)"}
            .bind(onNext: {
                self.quantity = $0
            } )
            .disposed(by: self.disposeBag)
    }
}
