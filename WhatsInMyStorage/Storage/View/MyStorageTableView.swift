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

/*
 재고 테이블 뷰
 */

class MyStorageTableView: UIView {
    
    struct Observable {
        var storageData = BehaviorRelay<[StorageData]>(value: [StorageData]())
    }
    
    let rx = Observable()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let disposeBag = DisposeBag()
    
    var indicatorView: LottieAnimationView!
    
    init(reactor: MyStorageReactor?) {
        super.init(frame: .zero)
        
        _ = self.tableView.then {
            $0.allowsSelection = false
            $0.separatorInset = .zero
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 56.0
            $0.rowHeight = UITableView.automaticDimension
            $0.dataSource = self
            $0.delegate = self
            $0.register(MyStorageTableViewHeader.self, forHeaderFooterViewReuseIdentifier: MyStorageTableViewHeader.reuseIdentifier)
            $0.register(MyStorageCell.self, forCellReuseIdentifier: "MyStorageCell")
        }
        
        self.addSubview(self.tableView)
        
        /// TODO: RxDataSource로 만들기
        self.rx.storageData
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }

                self.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        self.indicatorView = .init(name: "loading").then {
            $0.contentMode = .scaleAspectFit
        }
        self.addSubview(self.indicatorView)
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

extension MyStorageTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rx.storageData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyStorageCell", for: indexPath) as! MyStorageCell
        
        let data = self.rx.storageData.value
        cell.configure(storage: data[indexPath.row])
        cell.reactor = MyStorageCellReactor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // The UITableView will call the cell's sizeThatFit() method to compute the height.
        // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.rx.storageData.value.count > 0 {
            return 45.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStorageTableViewHeader.reuseIdentifier) as! MyStorageTableViewHeader
        
        header.configure(title: "Product")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}
