//
//  PopupViewController.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/26.
//

import UIKit
import PinLayout

class popupView: UIView {
    
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let productTextField = UITextField()
    let info2Label = UILabel()
    let quantityTextField = UITextField()
    let confirmButton = UIButton()
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        self.addSubview(titleLabel)
        _ = titleLabel.then {
            $0.backgroundColor = .purple
            $0.text = "재고 추가"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
        }
        
        self.addSubview(infoLabel)
        _ = infoLabel.then {
            $0.backgroundColor = .purple
            $0.text = "Product Name"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
        }
        
        self.addSubview(infoLabel)
        _ = infoLabel.then {
            $0.backgroundColor = .purple
            $0.text = "Product Name"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
        }
        
        self.addSubview(self.productTextField)
        _ = self.productTextField.then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.placeholder = "항목을 입력하세요."
            $0.backgroundColor = .yellow
        }
        
        self.addSubview(info2Label)
        _ = info2Label.then {
            $0.backgroundColor = .purple
            $0.text = "Quantity"
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
        }
    
        self.addSubview(self.quantityTextField)
        _ = self.quantityTextField.then {
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textColor = UIColor.black
            $0.placeholder = "항목을 입력하세요."
            $0.backgroundColor = .yellow
        }
        
        self.addSubview(self.confirmButton)
        _ = self.confirmButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.pin.top().horizontally().sizeToFit(.width)
        self.infoLabel.pin.below(of: self.titleLabel, aligned: .left).marginTop(10.0).horizontally().sizeToFit()
        self.productTextField.pin.below(of: self.infoLabel, aligned: .left).marginTop(10.0).horizontally().sizeToFit()
        self.info2Label.pin.below(of: self.productTextField, aligned: .left).marginTop(10.0).horizontally().sizeToFit()
        self.quantityTextField.pin.below(of: self.info2Label, aligned: .left).marginTop(10.0).horizontally().sizeToFit()
        self.confirmButton.pin.bottomCenter(10.0).horizontally(10.0).size(20%)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopupViewController: UIViewController {

    let popUpView = popupView()
    var completionHandler: ((String?, Int?) -> Void)?
    
    class func showPopup(targetViewController: UIViewController, completionHandler: @escaping ((String?, Int?) -> Void)) {
        
        let popupViewController = PopupViewController()
        popupViewController.completionHandler = completionHandler
        
        targetViewController.present(popupViewController, animated: true)
    }
    
    
    override func loadView() {
        super.loadView()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.view = self.popUpView
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.popUpView.pin.center().width(70%).height(50%)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
