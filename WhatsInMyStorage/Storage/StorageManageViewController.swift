//
//  StorageManageViewController.swift
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
class StorageManageViewController: CustomNavigationViewController, View {
    
    typealias Reactor = StorageManageReactor
    var disposeBag = DisposeBag()

    // UI
    lazy var editButton: UIButton = {
        let button = UIButton().then {
            $0.backgroundColor = .green
            $0.setTitle("편집", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 17.0, weight: .bold)
            $0.setTitleColor(UIColor.wms.green, for: .normal)
        }
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton().then {
            $0.backgroundColor = .green
            $0.setTitle("+", for: .normal)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 3.0, right: 0.0)
            $0.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
            $0.setTitleColor(UIColor.wms.green, for: .normal)
        }
        return button
    }()
    
    /// CustomNavigationBar를 하면 테이블뷰 header가 sticky 해지지 않는 이슈가 있어 따로 View로 뺀다.
    lazy var tableViewHeader: MyStorageTableViewHeader = {
        return  MyStorageTableViewHeader(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
    }()
    
    lazy var tableView: UITableView = {
        return UITableView(frame: .zero, style: .plain).then {
            $0.separatorStyle = .none
            $0.separatorInset = .zero
            $0.backgroundColor = .white
            $0.automaticallyAdjustsScrollIndicatorInsets = true 
            $0.contentInsetAdjustmentBehavior = .always // 이 키워드가 moveCell에 영향을 주고있음
            $0.contentInset = .zero
            if #available(iOS 15.0, *) {
                $0.sectionHeaderTopPadding = 0.0
            } else {
                // Fallback on earlier versions
            }
            
            $0.register(MyStorageTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStorageTableSectionHeaderView.reuseIdentifier)
            $0.register(StorageCell.self, forCellReuseIdentifier: "StorageCell")
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
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<MyStorageSectionData>! = {
        return RxTableViewSectionedReloadDataSource<MyStorageSectionData> { [weak self] dataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCell", for: indexPath) as! StorageCell
            cell.selectionStyle = .none
            /// @유현지 <궁금증>
            /// Cell안에 (-) (+) 버튼이 있고, 화면에 뿌려주는 StorageSectionData는 VC가 갖고있다.
            /// 따라서 Cell의 Reactor는 Action이 없고, Cell의 Action이 VC의 Reactor로 가야될 것 같은데
            /// ReactorKit에서는 Cell도 View라고 보고 Reacttor가 필요하다고 한다.
            cell.isExpandable = self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false
            cell.configure(storage: item)
        
            return cell
        }
    }()
    
    init(reactor: StorageManageReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    private func setUI() {
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.tableViewHeader)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.confirmButton)
        
        self.navigationBarView.addSubview(self.editButton)
        self.navigationBarView.addSubview(self.addButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "재고 관리"
        self.tableView.setEditing(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layout()
    }
    
    private func layout() {
        self.addButton.pin.vCenter().right(15.0).size(CGSize(width: 30.0, height: 30.0))
        self.editButton.pin.left(of: self.addButton, aligned: .center).marginRight(15.0).size(CGSize(width: 30.0, height: 30.0))
    
        self.tableViewHeader.pin.below(of: self.navigationBarView).horizontally().height(44.0)
        self.tableView.pin.below(of: self.tableViewHeader).horizontally().bottom(66.0)
        self.confirmButton.pin.bottomCenter().marginBottom(10.0).minWidth(self.tableView.frame.width - 50.0).height(56.0)
    }
    
    // setRx처럼 다루기?
    func bind(reactor: StorageManageReactor) {
        
        self.rx.viewDidLoad
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bindDataSource(reactor: reactor)
        
        self.bindTableViewRx(reactor: reactor)
        
        self.bindButton(reactor: reactor)
    }
    
    private func bindButton(reactor: StorageManageReactor) {
        
        // [Action] + 버튼
        self.addButton.rx.tap
            .map { Reactor.Action.openAddPopup }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // [State] + 버튼
        reactor
            .pulse(\.$openPopup)
            .skip(1)
            .bind(with: self, onNext: { object ,_ in
                object.openPopup()
            })
            .disposed(by: self.disposeBag)
        
        // [Action] editing 버튼
        self.editButton.rx.tap
            .map { Reactor.Action.editTask(!self.tableView.isEditing) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // [State] editing 버튼
        reactor
            .pulse(\.$isEditing)
            .bind(with: self, onNext: {
                $0.tableView.setEditing($1, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindDataSource(reactor: StorageManageReactor) {
        
        self.dataSource
            .canEditRowAtIndexPath = { (datasource, indexPath) in
                
                if self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) == true {
                    return false
                }
                
                
                return true
            }
    
        reactor
            .pulse(\.$storages)
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableViewRx(reactor: StorageManageReactor) {
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        // ControlEvent<ItemMovedEvent>가 (IndexPath), (IndexPath)라서 전달 가능
        self.tableView.rx.itemMoved
            .map(Reactor.Action.moveTask)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemDeleted
            .map(Reactor.Action.deleteTask)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor
            .pulse(\.$reloadSection)
            .bind(with: self, onNext: { object, section in
                object.tableView.reloadSections([section], animationStyle: .automatic)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func openPopup() {
        
        guard let reactor = self.reactor else { return }
        
        // 액션에 연결
        let StorageAddPopupViewController = StorageAddPopupViewController()
        
        StorageAddPopupViewController.rx.addedStorageData
            .map { Reactor.Action.addTask(reactor.currentState.storages, $0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.present(StorageAddPopupViewController, animated: true)
    }
}

extension StorageManageViewController: UITableViewDelegate {
    
    // The UITableView will call the cell's sizeThatFit() method to compute the height.
    // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false) ? .zero : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false) ? .zero : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.reactor?.currentState.storages.count ?? 0 > 0) ? 44.0 : .zero
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStorageTableSectionHeaderView.reuseIdentifier) as! MyStorageTableSectionHeaderView
        
        if let reactor = self.reactor {
            header.title = reactor.currentState.storages[section].header
            header.titleButton.rx.tap
                .map { Reactor.Action.expandSectionRows(section) }
                .bind(to: reactor.action)
                .disposed(by: header.disposeBag)
        }
 
        return header
    }
}


