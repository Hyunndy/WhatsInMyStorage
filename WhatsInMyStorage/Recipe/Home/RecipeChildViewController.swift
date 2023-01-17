//
//  RecipeChildViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import UIKit
import RxSwift

class RecipeChildViewController: UIViewController, ReactorViewControllerDelegate, UISettingDelegate {
    
    /// 데이터 나누는 기준
    public private(set) var sortedBy: String?
    
    typealias Reactor = RecipeReactor
    
    var disposeBag = DisposeBag()
    
    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
            $0.backgroundColor = .white
            $0.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        }
    }()
    var dataSource: UICollectionViewDiffableDataSource<Section, Recipe>?
    
    init(sortedBy: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.sortedBy = sortedBy
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        
        self.view.addSubview(self.collectionView)
        
        // 1. Connect a diffable Datasource to your collection View
        // 2. Implement a cell Provider to configure your collection view's cell
        let cellRegistration = UICollectionView.CellRegistration<RecipeCollectionViewCell, Recipe> { cell, indexPath, recipe in
            cell.configure(name: recipe.name, price: recipe.price, image: recipe.image)
        }
        
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: { collectionView,indexPath,recipe -> RecipeCollectionViewCell in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: recipe)
        })
        // 4. Display the data in the UI
        
    }
    
    func bind(reactor: RecipeReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    func bindAction(reactor: RecipeReactor) {
    
        /// View
        self.collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { (owner, indexPath) in
                
                owner.navigationController?.pushViewController(RecipeDetailViewController(), animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindState(reactor: RecipeReactor) {
        reactor.state.map { $0.recipeArray }
            .map {
                return (self.sortedBy == "All") ? $0 : $0.filter { $0.sortBy == self.sortedBy }
            }
            .bind(with: self, onNext: { (owner, recipe) in
                
                guard let dataSource = owner.dataSource else { return }
                
                // 3. Generate the current State of the data
                var snapshot = NSDiffableDataSourceSnapshot<Section, Recipe>()
                snapshot.appendSections([.recipe])
                snapshot.appendItems(recipe)
                dataSource.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(20.0)
        group.contentInsets = .init(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0.0
        section.contentInsets = .init(top: 0.0, leading: 0.0, bottom: 20.0, trailing: 0.0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.collectionView.pin.all()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        self.view.endEditing(true)
    }
}
