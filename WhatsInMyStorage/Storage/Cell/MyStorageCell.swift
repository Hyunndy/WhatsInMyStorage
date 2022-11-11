//
//  MyStorageCell.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation
import UIKit
import FlexLayout
import PinLayout

class MyStorageCell: UITableViewCell {
    
    static let reuseIdentifier = "MyStorageCell"
    
    private let minusButton = UIButton()
    private let plusButton = UIButton()
    private let quantityLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: MyStorageCell.reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        
        _ = self.minusButton.then {
            $0.setImage(UIImage(named: "heart_filled_24"), for: .normal)
        }//.pin.size(20)
        
        _ = self.quantityLabel.then {
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = UIColor.black
        }
        self.contentView.addSubview(self.quantityLabel)
        
        _ = self.plusButton.then {
            $0.setImage(UIImage(named: "heart_filled_24"), for: .normal)
        }
    }
    
    func configure(storage: StorageData) {
        self.quantityLabel.text = "\(storage.quantity)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    private func layout() {
        self.quantityLabel.pin.all()
//        self.minusButton.pin.after(of: self.quantityLabel, aligned: .center).size(CGSize(width: 48.0, height: 48.0))
//        self.plusButton.pin.after(of: self.minusButton, aligned: .center).size(CGSize(width: 48.0, height: 48.0))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        self.contentView.pin.width(size.width)

        layout()
//
        return CGSize(width: contentView.frame.width, height: 100.0)//self.quantityLabel.frame.maxY)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
