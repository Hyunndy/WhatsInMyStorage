//
//  ReactorKitPractice.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/15.
//

import Foundation
import UIKit
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa
import SafariServices

class customCell: UITableViewCell {
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "customCell")
        
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.titleLabel)
        _ = self.titleLabel.then {
            $0.font = .systemFont(ofSize: 14.0)
            $0.textColor = UIColor.black
            $0.textAlignment = .left
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.pin.all()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        self.contentView.pin.width(size.width)

        self.titleLabel.pin.all()

        return CGSize(width: contentView.frame.width, height: 60.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ReactorKitPractiveViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let searchViewController = UISearchController(searchResultsController: nil)
    
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.searchController = searchViewController
        
        self.view.addSubview(self.tableView)
        self.tableView.then {
            $0.backgroundColor = .white
            $0.register(customCell.self, forCellReuseIdentifier: "customCell")
            $0.delegate = self
            $0.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        searchViewController.isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableView.pin.all()
    }
}

extension ReactorKitPractiveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! customCell
        cell.titleLabel.text = "아이우에오"
        return cell
    }
}

extension ReactorKitPractiveViewController: View {
    
    typealias Reactor = ReactorKitPracticeReactor

    func bind(reactor: ReactorKitPracticeReactor) {
        
        self.setAction(reactor: reactor)
        self.setState(reactor: reactor)
        
    }
    
    private func setAction(reactor: ReactorKitPracticeReactor) {
        
        // 페이징 처리!
        self.tableView.rx.contentOffset
            .filter({ [weak self] offset in
                guard let self else { return false }
                
                return (offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100.0)
            })
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // search
        self.searchViewController.searchBar.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuary($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func setState(reactor: ReactorKitPracticeReactor) {

        // State
        // 아 이게뭔지 진짜 모르겠다
        reactor.state.map { $0.repose }
          .bind(to: tableView.rx.items(cellIdentifier: "cell")) { indexPath, repo, cell in
            cell.textLabel?.text = repo
          }
          .disposed(by: disposeBag)
    }
}

