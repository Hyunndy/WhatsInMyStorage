//
//  RecipeDetailViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/17.
//

/*
 UICompositionalLayout 적용
 */

import UIKit
import FlexLayout
import PinLayout

class PracticeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PracticeCollectionViewCell"
    
    private let rootFlexContainer = UIView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.font = .boldSystemFont(ofSize: 20.0)
        self.titleLabel.textColor = .black
        self.backgroundColor = .yellow
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    /// UICompositionalLayout의 estimate를 사용하기 위해 이 함수를 쓰지 않으면 먹지 않는다.
    func layout() {
        self.titleLabel.pin.all().sizeToFit(.widthFlexible)
        self.contentView.pin.width(self.titleLabel.frame.maxX)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layout()
        return contentView.frame.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PracticeCollectionViewCell2: UICollectionViewCell {
    
    static let identifier = "PracticeCollectionViewCell2"
    
    private let rootFlexContainer = UIView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.font = .boldSystemFont(ofSize: 20.0)
        self.titleLabel.textColor = .black
        self.titleLabel.numberOfLines = 0
        self.backgroundColor = .yellow
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    /// UICompositionalLayout의 estimate를 사용하기 위해 이 함수를 쓰지 않으면 먹지 않는다.
    func layout() {
        self.titleLabel.pin.all().sizeToFit(.heightFlexible)
        self.contentView.pin.height(self.titleLabel.frame.maxY)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layout()
        return contentView.frame.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class RecipeDetailViewController: CustomNavigationViewController, UISettingDelegate {
    
    enum Section: Int {
        case ingredient = 0
        case step = 1
    }
    
    struct IngredientItem: Hashable {
        let identifier = UUID()
        let name: String?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    struct recipeStepItem: Hashable {
        let identifier = UUID()
        let description: String?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    var ingredientData = [IngredientItem(name: "#매력적인"), IngredientItem(name: "#유명한"),IngredientItem(name: "#매력적인"), IngredientItem(name: "#유명한"),IngredientItem(name: "#매력적인"), IngredientItem(name: "#유명한"),IngredientItem(name: "#매력적인"), IngredientItem(name: "#유명한")]
    var recipeStepData = [recipeStepItem(description: "면을 삶으세요\n간장을 넣으세요"), recipeStepItem(description: "김치 넣으세요"), recipeStepItem(description: "면을 삶으세요"), recipeStepItem(description: "김치 넣으세요")]
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    
    lazy var headerView: RecipeDetailHeaderView = {
        return RecipeDetailHeaderView()
    }()
    
    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }()
    
    var dataSource: DataSource?
    
    private func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let layout =  UICollectionViewCompositionalLayout(sectionProvider: { (sectionIdx, enviroment) in
            switch sectionIdx {
            case Section.ingredient.rawValue:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(60.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(60.0), heightDimension: .absolute(32.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 6.0
                section.orthogonalScrollingBehavior = .continuous
                return section
            default:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 6.0
                return section
            }
        })
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10.0
        layout.configuration = config
        
        return layout
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    func setUI() {
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(PracticeCollectionViewCell.self, forCellWithReuseIdentifier: PracticeCollectionViewCell.identifier)
        self.collectionView.register(PracticeCollectionViewCell2.self, forCellWithReuseIdentifier: PracticeCollectionViewCell2.identifier)
        let recipeCellRegistraion = UICollectionView.CellRegistration<PracticeCollectionViewCell, IngredientItem> { (cell, indexPath, ingredient) in
            cell.titleLabel.text = ingredient.name
        }
        
        let stepCellRegistraion = UICollectionView.CellRegistration<PracticeCollectionViewCell2, recipeStepItem> { (cell, indexPath, step) in
            cell.titleLabel.text = step.description
        }

        self.dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) in

            if let ingredient = itemIdentifier as? IngredientItem {
                // 재료 Cell
                return collectionView.dequeueConfiguredReusableCell(using: recipeCellRegistraion, for: indexPath, item: ingredient)
            } else if let step = itemIdentifier as? recipeStepItem {
                // 스텝 Cell
                return collectionView.dequeueConfiguredReusableCell(using: stepCellRegistraion, for: indexPath, item: step)
            }
            
            else {
                return UICollectionViewCell()
            }
        })
        
        self.collectionView.collectionViewLayout = self.getCollectionViewLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.ingredient, .step])
        snapshot.appendItems(ingredientData, toSection: .ingredient)
        snapshot.appendItems(recipeStepData, toSection: .step)
        self.dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.headerView.pin.below(of: self.navigationBarView).horizontally()
        self.collectionView.pin.below(of: self.headerView).horizontally().bottom()
    }
}
