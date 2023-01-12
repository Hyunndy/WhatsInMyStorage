//
//  RecipeChildViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import UIKit
import RxSwift

class RecipeChildViewController: UIViewController, ReactorViewControllerDelegate, UISettingDelegate {

    typealias Reactor = RecipeReactor
    
    var disposeBag = DisposeBag()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var dataSource: UICollectionViewDiffableDataSource<Section, Recipe>!
    
    var recipeArray = [Recipe(name: "윌리도그", price: 6500, image: "kikiCake"), Recipe(name: "칠리도그", price: 7000, image: "kikiCake"), Recipe(name: "오레오크로플", price: 7000, image: "kikiCake")]
    
    func setUI() {
        
        self.view.addSubview(self.collectionView)
        self.collectionView.backgroundColor = .white
        self.collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        self.collectionView.collectionViewLayout = self.createLayout()
        
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
        
    }
    
    func bindState(reactor: RecipeReactor) {
        
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

        // 3. Generate the current State of the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Recipe>()
        snapshot.appendSections([.recipe])
        snapshot.appendItems(self.recipeArray)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.collectionView.pin.all()
    }
}
