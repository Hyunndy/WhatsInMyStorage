//
//  UserSettingViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import UIKit

class UserSettingViewController: UIViewController, UIViewControllerDelegate {
    
    typealias mainViewType = AutoSizingView
    var mainView: AutoSizingView {
        get {
            return self.view as! AutoSizingView
        }
    }
    
    func setLayout() {
        
    }
    
    override func loadView() {
        super.loadView()
        
        self.view = AutoSizingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.randomizeContent()
    }
    
    @objc
    private func randomizeContent() {
        ContentService.shared.fetchText(numberOfParagraph: 2) { [weak self] (result) in
            guard let strongSelf = self, case let .success(paragraphs) = result else { return }
            strongSelf.mainView.updateTexts(firstText: paragraphs[0], secondText: paragraphs[1])
        }

        Task {
            let image = try await ContentService.shared.asyncFetch(width: Int.random(in: 200..<500), height: Int.random(in: 200..<500))
            self.mainView.updateImage(image)
            
//        ContentService.shared.fetchImage(width: Int.random(in: 200..<500), height: Int.random(in: 200..<500)) { [weak self] (result) in
//            guard let strongSelf = self, case let .success(image) = result else { return }
//            strongSelf.mainView.updateImage(image)
        }
    }
    
    func setNavigationBar() {
        self.title = "설정"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.blue]
    }
    
    func setUI() {
        //
    }
    
    func setRx() {
        //
    }
}

extension UserSettingViewController: UITabBarItemControllerDelegate {
    internal var customTabBarItem: UITabBarItem {
        get {
            let tabBarImage = UIImage(named: "heart_filled_24")
            let tabBar = UITabBarItem(title: "설정", image: tabBarImage, tag: 1)
            return tabBar
        }
    }
}
