//
//  Refac_MyStorageManageReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/13.
//

import UIKit
import ReactorKit
import RxDataSources

typealias StorageSection = SectionModel<String, Refac_MyStorageCellReactor>

class Refac_MyStorageManageReactor: Reactor {
    
    enum Action {
        /// viewDidLoad, Refresh
        case refresh
        /// itemMoved
        case moveTask(IndexPath, IndexPath)
        /// itemDeleted
        case deleteTask(IndexPath)
    }

    enum Mutation {
        /// refresh
        case setStorages([StorageSection])
        /// itemMoved
        case moveStorageItem(IndexPath, IndexPath)
        /// itemDeleted
        case deleteStorageItem(IndexPath)
    }
    
    struct State {
        @Pulse var storages: [StorageSection]
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(storages: [StorageSection(model: "", items: [])])
    }
    
    /// Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return Observable.concat([
                self.getStorageData(page: 1)
                    .map { Mutation.setStorages($0) }
            ])
        default:
            return Observable.just(Mutation.deleteStorageItem(IndexPath(row: 1, section: 1)))
//        case .moveTask(let indexPath, let indexPath2):
//
//        case .deleteTask(let indexPath):
            
        }
    }
    
    /// Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStorages(let storages):
            newState.storages = storages
            return newState
        case .moveStorageItem(let indexPath, let indexPath2):
            return newState
        case .deleteStorageItem(let indexPath):
            return newState
        }
    }
}

extension Refac_MyStorageManageReactor {
    private func getStorageData(page: Int) -> Observable<[StorageSection]> {
        
        let storageData = [StorageData(product: "양파", quantity: 1),
                           StorageData(product: "가공육", quantity: 2),
                           StorageData(product: "토마토", quantity: 3),
                           StorageData(product: "소세지", quantity: 4)]
        
        var reactorArray = [Refac_MyStorageCellReactor]()
        for storageDatum in storageData {
            reactorArray.append(Refac_MyStorageCellReactor(data: storageDatum))
        }
        
        return Observable.just([StorageSection(model: "핫도그", items: reactorArray)])
    }
}
