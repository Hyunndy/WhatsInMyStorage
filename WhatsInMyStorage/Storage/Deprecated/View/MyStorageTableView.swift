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
        /// 재고 목록 Section Data
        unowned var storageSectionData: BehaviorRelay<[MyStorageSectionData]>!
    }
    
    var rx = Observable()
    
    let disposeBag = DisposeBag()
    
    var expandableSet = Set<Int>()
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var indicatorView: LottieAnimationView!
    
    let confirmButton = UIButton()
    
    var dataSource: RxTableViewSectionedReloadDataSource<MyStorageSectionData>!
    
    func setUI() {
        self.addSubview(self.tableView)
        _ = self.tableView.then {
            $0.allowsSelection = false
            $0.separatorInset = .zero
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 56.0
            if #available(iOS 15.0, *) {
                $0.sectionHeaderTopPadding = 0.0
            }
            $0.automaticallyAdjustsScrollIndicatorInsets = false
            
            let header = MyStorageTableViewHeader(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 45.0))
            $0.tableHeaderView = header
            
            $0.register(MyStorageTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStorageTableSectionHeaderView.reuseIdentifier)
            $0.register(MyStorageCell.self, forCellReuseIdentifier: "MyStorageCell")
        }
        
        self.indicatorView = .init(name: "loading").then {
            $0.contentMode = .scaleAspectFit
        }
        self.addSubview(self.indicatorView)
        
        self.addSubview(self.confirmButton)
        _ = self.confirmButton.then {
            $0.backgroundColor = UIColor.wms.green
            $0.setTitle("저장하기", for: .normal)
            $0.layer.cornerRadius = 5.0
            $0.clipsToBounds = true
        }
    }
    
    func setRx() {
        
        // CollectionView.DataSource 세팅
        self.dataSource = RxTableViewSectionedReloadDataSource<MyStorageSectionData> { [weak self] dataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyStorageCell", for: indexPath) as! MyStorageCell
            
            cell.isExpandable = self.expandableSet.contains(indexPath.section)
            
            print("섹션 \(indexPath.section) Cell의 isExpandable = \(cell.isExpandable)")
            
            cell.configure(storage: item)
            cell.reactor = MyStorageCellReactor(quantity: item.quantity)
            
            cell.rx.changeQuantity
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    
                    var value = self.rx.storageSectionData.value
                    value[indexPath.section].items[indexPath.row].quantity = $0
                    
                    self.rx.storageSectionData.accept(value)
                    
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        }
        
        // CollectionView.Delegate 세팅
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.dataSource
            .canEditRowAtIndexPath = { (_, indexPath) in
                
                if self.expandableSet.contains(indexPath.section) == true {
                    return false
                } else {
                    return true
                }
            }
        
        self.dataSource
            .canMoveRowAtIndexPath = { (a, _) in
                return true
            }

        self.tableView.rx.itemMoved
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind { [weak self] tableView, indexPath in
                guard let self else { return }
                
                let sourceIndexPath = indexPath.sourceIndex
                let destinationIndexPath = indexPath.destinationIndex
                
                var sectionDataArray = self.rx.storageSectionData.value
                
                let swapData: StorageData = sectionDataArray[sourceIndexPath.section].items[sourceIndexPath.item]
                
                sectionDataArray[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
                
                sectionDataArray[destinationIndexPath.section].items.insert(swapData, at: destinationIndexPath.item)
            
                // 최종 데이터 업데이트
                self.rx.storageSectionData.accept(sectionDataArray)
            }
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemDeleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind { [weak self] tableView, indexPath in
                guard let self else { return }
                
                var sectionDataArray = self.rx.storageSectionData.value
                
                // 현재 섹션
                var currentSection = sectionDataArray[indexPath.section]
                
                // 현재 섹션의 아이템 제거
                currentSection.items.remove(at: indexPath.row)
                
                // 섹션 업데이트!
                sectionDataArray[indexPath.section] = currentSection
                
                // 최종 데이터 업데이트
                self.rx.storageSectionData.accept(sectionDataArray)
            }
            .disposed(by: self.disposeBag)
        
        /// 섹션 데이터 <-> dataSource 연결
        self.rx.storageSectionData
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    init(storageData: BehaviorRelay<[MyStorageSectionData]>) {
        super.init(frame: .zero)

        self.rx.storageSectionData = storageData
        
        self.setUI()
        self.setRx()
    }
    
    private func layout() {
        self.indicatorView.pin.center().sizeToFit()
        self.tableView.pin.all().marginBottom(100.0)
        self.confirmButton.pin.bottomCenter(to: self.tableView.anchor.bottomCenter).marginBottom(10.0).minWidth(self.tableView.frame.width - 50.0).height(56.0)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.expandableSet.contains(indexPath.section) {
            return 0.0
        } else {
            // The UITableView will call the cell's sizeThatFit() method to compute the height.
            // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.expandableSet.contains(indexPath.section) {
            return 0.0
        } else {
            // The UITableView will call the cell's sizeThatFit() method to compute the height.
            // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
            return UITableView.automaticDimension
        }
        
       
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let data = self.rx.storageSectionData.value[section]
        if data.items.count > 0 {
            return 50.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStorageTableSectionHeaderView.reuseIdentifier) as! MyStorageTableSectionHeaderView

        header.title = self.rx.storageSectionData.value[section].header
        header.titleButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                print("터치된 Section \(section)")
                
                if self.expandableSet.contains(section) {
                    self.expandableSet.remove(section)
                } else {
                    self.expandableSet.insert(section)
                }
                
                self.tableView.reloadSections([section], animationStyle: .automatic)
            }).disposed(by: header.disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
}
