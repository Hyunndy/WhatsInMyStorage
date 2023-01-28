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
    
    func removeUnderline(backTo fontColor: UIColor) {
        guard let title = title(for: .normal) else { return }
        
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15.0), range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: title.count))
        setAttributedTitle(attributedString, for: .normal)
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
