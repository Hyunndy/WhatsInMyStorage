//
//  UIVIew+Extension.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/02.
//

import Foundation
import UIKit

extension UITextField {
    func addLeftPadding(padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: padding, height: self.frame.height))
        self.leftView = view
        self.leftViewMode = .always
    }
}
