//
//  MyStorageTableView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Lottie
import RxDataSources

/*
 재고 테이블 뷰
 */

class MyStorageTableView: UIView {
    
    struct Observable {
        var storageSectionData = BehaviorRelay<[MyStorageSectionData]>(value: [MyStorageSectionData(items: [StorageData]())])
    }
    
    let rx = Observable()
    let disposeBag = DisposeBag()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    var indicatorView: LottieAnimationView!
    
    var dataSource: RxTableViewSectionedReloadDataSource<MyStorageSectionData>!
    
    func setUI() {
        self.addSubview(self.tableView)
        _ = self.tableView.then {
            $0.allowsSelection = false
            $0.separatorInset = .zero
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 56.0
            $0.rowHeight = UITableView.automaticDimension
            $0.register(MyStorageTableViewHeader.self, forHeaderFooterViewReuseIdentifier: MyStorageTableViewHeader.reuseIdentifier)
            $0.register(MyStorageCell.self, forCellReuseIdentifier: "MyStorageCell")
        }
        
        self.indicatorView = .init(name: "loading").then {
            $0.contentMode = .scaleAspectFit
        }
        self.addSubview(self.indicatorView)
    }
    
    func setRx() {
        self.dataSource = RxTableViewSectionedReloadDataSource<MyStorageSectionData> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyStorageCell", for: indexPath) as! MyStorageCell
            cell.configure(storage: item)
            cell.reactor = MyStorageCellReactor(quantity: item.quantity)
            return cell
        }
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.rx.storageSectionData
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    init() {
        super.init(frame: .zero)

        self.setUI()
        self.setRx()
    }
    
    private func layout() {
        self.indicatorView.pin.center().sizeToFit()
        self.tableView.pin.all()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyStorageTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // The UITableView will call the cell's sizeThatFit() method to compute the height.
        // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let data = self.rx.storageSectionData.value[0]
        if data.items.count > 0 {
            return 45.0
        } else {
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStorageTableViewHeader.reuseIdentifier) as! MyStorageTableViewHeader

        return header
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    }
}
