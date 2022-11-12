//
//  MyStorageTableView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import ReactorKit

/*
 재고 테이블 뷰
 */

class MyStorageTableView: UIView {
    
    weak var vcReactor: MyStorageReactor?
    let tableView = UITableView(frame: .zero, style: .grouped)
    private var storageArray = [StorageData]()
    
    init(reactor: MyStorageReactor?) {
        super.init(frame: .zero)
        
        self.vcReactor = reactor
        
        _ = self.tableView.then {
            $0.allowsSelection = false
            $0.separatorInset = .zero
//            $0.separatorStyle = .singleLine
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 56.0
            $0.rowHeight = UITableView.automaticDimension
            $0.dataSource = self
            $0.delegate = self
            $0.register(MyStorageTableViewHeader.self, forHeaderFooterViewReuseIdentifier: MyStorageTableViewHeader.reuseIdentifier)
            $0.register(MyStorageCell.self, forCellReuseIdentifier: "MyStorageCell")
        }
        
        self.addSubview(self.tableView)
    }
    
    private func layout() {
        self.tableView.pin.all()
    }
    
    func configure(storage: [StorageData]) {
        self.storageArray = storage
        self.tableView.reloadData()
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
        return storageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyStorageCell", for: indexPath) as! MyStorageCell
        cell.configure(storage: self.storageArray[indexPath.row])
        cell.reactor = MyStorageCellReactor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // The UITableView will call the cell's sizeThatFit() method to compute the height.
        // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
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
