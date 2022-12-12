//
//  Refac_MyStorageManageViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/13.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import PinLayout
import RxDataSources
import Then

/*
 
 ReactorKit
    - View: 오직 UI만, Action 방출
    - Reactor: 오직 Stream 방출

 */
class Refac_MyStorageManageViewController: UIViewController, View {
    
    typealias Reactor = Refac_MyStorageManageReactor
    var disposeBag = DisposeBag()

    // UI
    lazy var tableView: UITableView = {
        return UITableView(frame: .zero, style: .plain).then {
            $0.separatorInset = .zero
            $0.allowsSelection = false
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 56.0
            $0.automaticallyAdjustsScrollIndicatorInsets = false
            
            let header = MyStorageTableViewHeader(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 45.0))
            $0.tableHeaderView = header
            
            $0.register(MyStorageTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStorageTableSectionHeaderView.reuseIdentifier)
            $0.register(Refac_MyStorageCell.self, forCellReuseIdentifier: "Refac_MyStorageCell")
        }
    }()
    
    lazy var confirmButton: UIButton = {
        return UIButton().then {
            $0.backgroundColor = UIColor.wms.green
            $0.setTitle("저장하기", for: .normal)
            $0.layer.cornerRadius = 5.0
            $0.clipsToBounds = true
        }
    }()
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<StorageSection>! = {
       return RxTableViewSectionedReloadDataSource<StorageSection> { [weak self] dataSource, tableView, indexPath, item in
           guard let self else { return UITableViewCell() }
           
           let cell = tableView.dequeueReusableCell(withIdentifier: "Refac_MyStorageCell", for: indexPath) as! Refac_MyStorageCell

           cell.reactor = item

//           cell.reactor?.action
               
           
           return cell
       }
    }()
    
    init(reactor: Refac_MyStorageManageReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView()
    }
    
    private func setUI() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.confirmButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.layout()
    }
    
    private func layout() {
        self.tableView.pin.all()
        self.confirmButton.pin.bottomCenter(to: self.tableView.anchor.bottomCenter).marginBottom(10.0).minWidth(self.tableView.frame.width - 50.0).height(56.0)
    }
    
    // setRx처럼 다루기?
    func bind(reactor: Refac_MyStorageManageReactor) {
        
        self.rx.viewDidLoad
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.setDataSource(reactor: reactor)
        
        self.setTableViewRx(reactor: reactor)
        
    }
    
    private func setDataSource(reactor: Refac_MyStorageManageReactor) {
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.dataSource
            .canEditRowAtIndexPath = { (_, indexPath) in
                return true
//                if self.expandableSet.contains(indexPath.section) == true {
//                    return false
//                } else {
//                    return true
//                }
            }
        
        self.dataSource
            .canMoveRowAtIndexPath = { (_, _) in
                return true
            }
        
        reactor
            .skipInitPulse(\.$storages)
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    private func setTableViewRx(reactor: Refac_MyStorageManageReactor) {
        self.tableView.rx.itemMoved
            .map(Reactor.Action.moveTask)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemDeleted
            .map(Reactor.Action.deleteTask)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
    }
    
    
}

extension Refac_MyStorageManageViewController: UITableViewDelegate {
    
}

public extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
