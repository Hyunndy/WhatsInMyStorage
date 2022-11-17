//
//  ReactorKitPractice.swift
//  WhatsInMyStorage
//x
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
    var data = [String]()
    
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.searchController = searchViewController
        
        self.view.addSubview(self.tableView)
        self.tableView.then {
            $0.backgroundColor = .white
            $0.register(customCell.self, forCellReuseIdentifier: "customCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchViewController.isActive = true
        

        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.tableView.rx.setDataSource(self).disposed(by: self.disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableView.pin.all()
    }
}

extension ReactorKitPractiveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! customCell
        cell.titleLabel.text = self.data[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
        guard let url = URL(string: "https://github.com/\(repo)") else { return }
        let viewController = SFSafariViewController(url: url)
        self.searchViewController.present(viewController, animated: true, completion: nil)
    }
}

extension ReactorKitPractiveViewController: View {
    
    typealias Reactor = ReactorKitPracticeReactor

    /*
     Action
     1) SearchBar에서 검색어 입력
     
     
     */
    private func bindAction(reactor: ReactorKitPracticeReactor) {
        
        /*
         Action.updateQuery
         */
        searchViewController.searchBar.rx.text // SearchBar에 들어오는 text의 ControlProperty
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance) // throttle: 지정한 주기 안에 가장 마지막에 들어온 하나의 Event만을 구독자에게 전달한다.
          .map { Reactor.Action.updateQuery($0) } // 방출된 text를 Reactor.Action.updateQuery($0) 형태로 구독자에게 전달한다.
          .bind(to: reactor.action) // reactor의 ActionSubject에 bind 시켜서 방출시킨다!!
          .disposed(by: disposeBag)

        
        tableView.rx.contentOffset
          .filter { [weak self] offset in
              print(offset)
              
              
            guard let `self` = self else { return false }
            guard self.tableView.frame.height > 0 else { return false }
            return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
          }
          .map { _ in Reactor.Action.loadNextPage }
          .bind(to: reactor.action)
          .disposed(by: disposeBag)
    }
    
    func bind(reactor: ReactorKitPracticeReactor) {
    
        self.bindAction(reactor: reactor)
        // State
        reactor.state.map { $0.repos }
            .bind(onNext: { [weak self] repo in
                guard let self else { return }
                
                self.data = repo
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }).disposed(by: self.disposeBag)
//          .bind(to: tableView.rx.items(cellIdentifier: "customCell")) { indexPath, repo, cell in
//            cell.textLabel?.text = repo
//          }
//          .disposed(by: disposeBag)

        // View
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self, weak reactor] indexPath in
            
            guard let `self` = self else { return }
            self.view.endEditing(true)
            self.tableView.deselectRow(at: indexPath, animated: false)
            guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
            guard let url = URL(string: "https://github.com/\(repo)") else { return }
            let viewController = SFSafariViewController(url: url)
            self.searchViewController.present(viewController, animated: true, completion: nil)
            
            
        }).disposed(by: self.disposeBag)
    }
}

