//
//  UIColor+Extension.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/20.
//

import Foundation
import UIKit
import ReactorKit

extension UIColor {
    struct wms {
        static let gray = UIColor(red: 0.961, green: 0.965, blue: 0.984, alpha: 1)
        static let blue = UIColor(red: 0.294, green: 0.478, blue: 1, alpha: 1)
        static let green = UIColor(red: 0.1922, green: 0.4745, blue: 0.3451, alpha: 1.0)
    }
}

extension Reactor {
    
    /// Reactor를 이용하여 데이터를 받을 때, initState가 UI가 그려지기 전에 불려 pinLayout이 깨져버리는 상황이 발생하여 초기 상태를 skip
    /// VC를 push해준 후에 Reactor를 세팅해서 UI가 로드된 후 reactor를 binding시켜도 되지만, 이거 쓰는게 더 나을듯 하다.
    public func skipInitPulse<Result>(_ transformToPulse: @escaping (State) throws -> Pulse<Result>) -> Observable<Result> {
        return self.state
            .map(transformToPulse).distinctUntilChanged(\.valueUpdatedCount).map(\.value)
//            .skip(1)
    }
}
