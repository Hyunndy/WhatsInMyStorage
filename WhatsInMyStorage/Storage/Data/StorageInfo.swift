//
//  StorageInfo.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/11.
//

import Foundation

struct StorageData: Equatable {
    let product: String
    var quantity: Int
    
    static func == (lhs: StorageData, rhs: StorageData) -> Bool {
        return (lhs.product == rhs.product)
    }
}
