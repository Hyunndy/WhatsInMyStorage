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
    let identifier = UUID()
    
    var name: String
    var price: Int
    var image: String
    var sortBy: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
