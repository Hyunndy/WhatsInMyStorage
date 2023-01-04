//
//  StorageTableViewHeader.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/12.
//

import Foundation
import UIKit

final class StorageTableViewHeader: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel().then {
            $0.text = "제품"
            $0.textColor = UIColor.wms.green
            $0.textAlignment = .left
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
        
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel().then {
            $0.text = "수량"
            $0.textColor = UIColor.wms.green
            $0.textAlignment = .left
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
    }
    
    private func setUI() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.quantityLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.pin.vCenter().left(24.0).sizeToFit()
        self.quantityLabel.pin.vCenter().right((24.0 + 30.0 + 50.0) / 2.0).sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
