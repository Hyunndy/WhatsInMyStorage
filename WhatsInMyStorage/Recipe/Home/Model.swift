//
//  Model.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import Foundation

enum Section: CaseIterable {
    case recipe
}

struct Recipe: Hashable, Equatable {
    var name: String
    var price: Int
    var image: String
    var sortBy: String
}
