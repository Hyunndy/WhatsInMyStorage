//
//  MyStorageTableSectionHeaderView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/10.
//

import UIKit

class MyStorageTableSectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "MyStorageTableSectionHeader"
    
    private let titleLabel = UILabel()
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setUI()
    }
    
    private func setUI() {
        
        self.contentView.addSubview(self.titleLabel)
        _ = self.titleLabel.then {
            $0.textColor = UIColor.wms.blue
            $0.textAlignment = .left
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.pin.vCenter().left(24.0).sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
