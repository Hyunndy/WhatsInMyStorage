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
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        return button
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        return button
    }()
    
    lazy var tableView: UITableView = {
        return UITableView(frame: .zero, style: .plain).then {
            $0.separatorInset = .zero
            $0.backgroundColor = .brown
            $0.estimatedRowHeight = 60.0
            $0.automaticallyAdjustsScrollIndicatorInsets = true 
            $0.contentInsetAdjustmentBehavior = .always
            $0.contentInset = .zero
            if #available(iOS 15.0, *) {
                $0.sectionHeaderTopPadding = 0.0
            } else {
                // Fallback on earlier versions
            }
            
            let header = MyStorageTableViewHeader(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 40.0))
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
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<MyStorageSectionData>! = {
        return RxTableViewSectionedReloadDataSource<MyStorageSectionData> { [weak self] dataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Refac_MyStorageCell", for: indexPath) as! Refac_MyStorageCell
            
            /// @유현지 <궁금증>
            /// Cell안에 (-) (+) 버튼이 있고, 화면에 뿌려주는 StorageSectionData는 VC가 갖고있다.
            /// 따라서 Cell의 Reactor는 Action이 없고, Cell의 Action이 VC의 Reactor로 가야될 것 같은데
            /// ReactorKit에서는 Cell도 View라고 보고 Reacttor가 필요하다고 한다.
            //           cell.reactor = item
            cell.quantity = "\(item.quantity)"
            cell.product = item.product
            cell.isExpandable = self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false
            
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
        
        self.tableView.setEditing(false, animated: true)
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        
        self.title = "재고 관리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItems = [self.addButton, self.editButton]
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        self.tableView.pin.top(self.view.pin.safeArea.top).horizontally().bottom()
        self.confirmButton.pin.bottomCenter(to: self.tableView.anchor.bottomCenter).marginBottom(10.0).minWidth(self.tableView.frame.width - 50.0).height(56.0)
    }
    
    // setRx처럼 다루기?
    func bind(reactor: Refac_MyStorageManageReactor) {
        
        self.rx.viewDidLoad
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bindDataSource(reactor: reactor)
        
        self.bindTableViewRx(reactor: reactor)
        
        self.bindButton(reactor: reactor)
    }
    
    private func bindButton(reactor: Refac_MyStorageManageReactor) {
        
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
    
    private func bindDataSource(reactor: Refac_MyStorageManageReactor) {
        
        self.dataSource
            .canEditRowAtIndexPath = { (_, indexPath) in
                return true
//                if self.expandableSet.contains(indexPath.section) == true {
//                    return false
//                } else {
//                    return true
//                }
            }
    
        reactor
            .pulse(\.$storages)
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableViewRx(reactor: Refac_MyStorageManageReactor) {
        
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
        let popupViewController = PopupViewController()
        
        popupViewController.rx.addedStorageData
            .map { Reactor.Action.addTask(reactor.currentState.storages, $0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.present(popupViewController, animated: true)
    }
}

extension Refac_MyStorageManageViewController: UITableViewDelegate {
    
    // The UITableView will call the cell's sizeThatFit() method to compute the height.
    // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("Cell 높이22 : \(UITableView.automaticDimension)")
        
        return (self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false) ? .zero : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        print("Cell 높이 : \(UITableView.automaticDimension)")
        
        
        return (self.reactor?.currentState.expandedSectionSet.contains(indexPath.section) ?? false) ? .zero : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.reactor?.currentState.storages.count ?? 0 > 0) ? 50.0 : .zero
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
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}


