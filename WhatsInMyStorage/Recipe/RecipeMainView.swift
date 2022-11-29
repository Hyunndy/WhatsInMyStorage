//
//  RecipeMainView.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/29.
//

import UIKit
import PinLayout

class RecipeMainView: UIView {

    private let collectionView: UICollectionView
    private let flowLayout = UICollectionViewFlowLayout()
    private let cellTemplate = RecipeCell()
    
    private var recipes = [Recipe]()
    
    init() {
        
        // init 전에 선언하는 이유는..?
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.flowLayout.minimumLineSpacing = 8.0
        self.flowLayout.minimumInteritemSpacing = 0.0
        
        self.addSubview(self.collectionView)
        _ = self.collectionView.then {
            $0.backgroundColor = .white
            $0.dataSource = self
            $0.delegate = self
            $0.register(RecipeCell.self, forCellWithReuseIdentifier: RecipeCell.reuseIdentifier)
        }
    }
    
    func configure(recipes: [Recipe]) {
        self.recipes = recipes
        
        self.collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecipeMainView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCell.reuseIdentifier, for: indexPath) as! RecipeCell
        
        cell.configure(recipe: self.recipes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        return CGSize(width: 200.0, height: 200.0)
        cellTemplate.configure(recipe: self.recipes[indexPath.row])
        // cellTemplate로 configure
        
        return self.cellTemplate.sizeThatFits(CGSize(width: 200.0, height: 200.0))
    }
}
