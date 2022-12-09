//
//  MyStorageTableSectionHeaderView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/10.
//

import UIKit
import RxSwift

class MyStorageTableSectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "MyStorageTableSectionHeader"
    
    let titleButton = UIButton()
    
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
        _ = self.titleButton.then {
            $0.setTitleColor(.wms.blue, for: .normal)
            $0.titleLabel?.textAlignment = .left
            $0.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
            $0.backgroundColor = .yellow
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleButton.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
