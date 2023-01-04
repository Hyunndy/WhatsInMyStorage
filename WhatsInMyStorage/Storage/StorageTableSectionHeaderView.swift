//
//  StorageTableSectionHeaderView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/10.
//

import UIKit
import RxSwift

class StorageTableSectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "MyStorageTableSectionHeader"
    
    lazy var titleButton: UIButton = {
        let button = UIButton().then {
            $0.setTitleColor(.wms.green, for: .normal)
            $0.titleLabel?.textAlignment = .left
            $0.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
            $0.contentHorizontalAlignment = .left
            $0.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 0.0)
            $0.layer.borderWidth = 2.0
            $0.layer.borderColor = UIColor.wms.gray.cgColor
            $0.clipsToBounds = true
        }
        
        return button
    }()
    
    var title: String? {
        didSet {
            self.titleButton.setTitle(title, for: .normal)
        }
    }
    
    var disposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    private func setUI() {
        
        self.contentView.addSubview(self.titleButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleButton.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
