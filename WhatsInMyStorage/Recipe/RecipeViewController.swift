//
//  RecipeViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/29.
//

import UIKit
import RxSwift

struct Recipe {
    var name: String
    var price: Int
    var mainImageURL: String
}

class RecipeViewController: UIViewController, ReactorViewControllerDelegate {
    
    typealias Reactor = RecipeReactor
    
    typealias mainViewType = RecipeMainView
    
    var disposeBag = DisposeBag()
    
    var mainView: RecipeMainView {
        get {
            return self.view as! mainViewType
        }
    }
    
    override func loadView() {
        super.loadView()
        
        self.setUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUI() {
        self.view = RecipeMainView()
        
        self.mainView.configure(recipes: [
            Recipe(name: "케이크", price: 2000, mainImageURL: "kikiCake")
        
        ])
    }
    
    func bind(reactor: RecipeReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    func bindAction(reactor: RecipeReactor) {
        <#code#>
    }
    
    func bindState(reactor: RecipeReactor) {
        <#code#>
    }
}
