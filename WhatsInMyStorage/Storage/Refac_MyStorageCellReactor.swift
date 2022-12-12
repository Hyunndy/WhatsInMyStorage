//
//  Refac_MyStorageCellReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/13.
//

import UIKit
import ReactorKit

class Refac_MyStorageCellReactor: Reactor {
    typealias Action = NoAction
    
    typealias State = StorageData
    
    let initialState: State
    
    init(data: State) {
        self.initialState = data
    }
}
