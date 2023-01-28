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
import ReactorKit
import RxSwift

class PracticeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PracticeCollectionViewCell"
    
    private let rootFlexContainer = UIView()
    lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = .black
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.contentView.addSubview(self.titleLabel)
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
    lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = .black
            $0.numberOfLines = 0
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.contentView.addSubview(self.titleLabel)
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

class RecipeDetailViewController: UIViewController, UISettingDelegate {
    
    var disposeBag = DisposeBag()
    
    let viewModel = RecipeDetailViewModel()
    
    enum Section: Int {
        case ingredient = 0
        case step = 1
        case otherRecipe = 2
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
    var OtherRecipeArray = [Recipe(name: "윌리도그2", price: 6500, image: "kikiCake", sortBy: "음료"), Recipe(name: "칠리도그2", price: 7000, image: "kikiCake", sortBy: "디저트"), Recipe(name: "오레오크로플2", price: 7000, image: "kikiCake", sortBy: "음료")]
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    
//    lazy var headerView: RecipeDetailHeaderView = {
//        return RecipeDetailHeaderView()
//    }()
    
    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }()
    
    var dataSource: DataSource?
    
    lazy var confirmButton: UIButton = {
        return UIButton().then {
            $0.backgroundColor = UIColor.wms.green
            $0.setTitle("삭제하기", for: .normal)
            $0.layer.cornerRadius = 5.0
            $0.clipsToBounds = true
        }
    }()
    
    private func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let layout =  UICollectionViewCompositionalLayout(sectionProvider: { (sectionIdx, enviroment) in
            
            // 푸터
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(10.0))
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
            sectionFooter.contentInsets = .init(top: 5.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
            
            switch sectionIdx {
            case Section.ingredient.rawValue:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(60.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(60.0), heightDimension: .absolute(32.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // 헤더
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250.0))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10.0, leading: 5.0, bottom: 0.0, trailing: 0.0)
                section.interGroupSpacing = 6.0
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
                
                return section
            case Section.otherRecipe.rawValue:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0.0, leading: 5.0, bottom: 0.0, trailing: 0.0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(200.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0.0
                section.orthogonalScrollingBehavior = .continuous
                return section
            default:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = .init(top: 0.0, leading: 5.0, bottom: 0.0, trailing: 0.0)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 6.0
                section.boundarySupplementaryItems = [sectionFooter]
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
//        self.view.addSubview(self.headerView)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(PracticeCollectionViewCell.self, forCellWithReuseIdentifier: PracticeCollectionViewCell.identifier)
        self.collectionView.register(PracticeCollectionViewCell2.self, forCellWithReuseIdentifier: PracticeCollectionViewCell2.identifier)
        self.collectionView.register(RecipeDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: RecipeDetailHeaderView.identifier)
        self.collectionView.register(LineSeperatorFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LineSeperatorFooterView.identifier)
        self.collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        
        let recipeCellRegistraion = UICollectionView.CellRegistration<PracticeCollectionViewCell, IngredientItem> { (cell, indexPath, ingredient) in
            cell.titleLabel.text = ingredient.name
        }
        
        let stepCellRegistraion = UICollectionView.CellRegistration<PracticeCollectionViewCell2, recipeStepItem> { (cell, indexPath, step) in
            cell.titleLabel.text = step.description
        }
        
        let otherRecipeCellRegistration = UICollectionView.CellRegistration<RecipeCollectionViewCell, Recipe>   (handler: { (cell, indexPath, recipe) in
            cell.configure(name: recipe.name, price: recipe.price, image: recipe.image)
        })
        
        let headerViewRegistration = UICollectionView.SupplementaryRegistration<RecipeDetailHeaderView>(elementKind: UICollectionView.elementKindSectionHeader, handler: { (view, string, indexPath) in
            view.nameLabel.text = "아이우에오"
        })
        
        let footerViewRegistration = UICollectionView.SupplementaryRegistration<LineSeperatorFooterView>(elementKind: UICollectionView.elementKindSectionFooter, handler: { (view, string, IndexPath) in
            view.backgroundColor = UIColor.wms.gray
        })

        self.dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) in

            if let ingredient = itemIdentifier as? IngredientItem {
                // 재료 Cell
                return collectionView.dequeueConfiguredReusableCell(using: recipeCellRegistraion, for: indexPath, item: ingredient)
            } else if let step = itemIdentifier as? recipeStepItem {
                // 스텝 Cell
                return collectionView.dequeueConfiguredReusableCell(using: stepCellRegistraion, for: indexPath, item: step)
            } else if let otherRecipe = itemIdentifier as? Recipe {
                // 다른 레시피 Cell
                return collectionView.dequeueConfiguredReusableCell(using: otherRecipeCellRegistration, for: indexPath, item: otherRecipe)
            } else {
                return UICollectionViewCell()
            }
        })
        
        self.dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) in

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerViewRegistration, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerViewRegistration, for: indexPath)
            default:
                return nil
            }
        }
        
        self.collectionView.collectionViewLayout = self.getCollectionViewLayout()
        
        self.view.addSubview(self.confirmButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.ingredient, .step, .otherRecipe])
        snapshot.appendItems(ingredientData, toSection: .ingredient)
        snapshot.appendItems(recipeStepData, toSection: .step)
        snapshot.appendItems(OtherRecipeArray, toSection: .otherRecipe)
        self.dataSource?.apply(snapshot, animatingDifferences: true)
        
        self.viewModel.fetch()
        
        self.viewModel.relay
            .subscribe({
                print($0)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //
//        self.headerView.pin.below(of: self.navigationBarView).horizontally().width(100%).sizeToFit(.width)
        self.collectionView.pin.top().horizontally().bottom(10.0)
        
//        self.confirmButton.pin.below(of: self.collectionView).horizontally(10.0).height(56.0).bottom()
    }
}
