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

extension UIButton {
    func setUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.thick.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 25.0), range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.underlineColor, value: UIColor.wms.green, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: title.count))
        setAttributedTitle(attributedString, for: .normal)
    }
}
