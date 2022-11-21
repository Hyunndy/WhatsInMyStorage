//
//  MyStorageTableViewHeader.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/12.
//

import Foundation
import UIKit

class MyStorageTableViewHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "MyStorageTableHeader"
    
    private let titleLabel = UILabel()
    private let quantityLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setUI()
    }
    
    private func setUI() {
        
        self.contentView.addSubview(self.titleLabel)
        _ = self.titleLabel.then {
            $0.text = "Product"
            $0.textColor = UIColor.wms.blue
            $0.textAlignment = .left
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
        
        self.contentView.addSubview(self.quantityLabel)
        _ = self.quantityLabel.then {
            $0.text = "Quantity"
            $0.textColor = UIColor.wms.blue
            $0.textAlignment = .left
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.pin.vCenter().left(24.0).sizeToFit()
        self.quantityLabel.pin.vCenter().right((24.0 + 30.0 + 12.0 + 50.0 + 12.0 + 30.0) / 2.0).sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
