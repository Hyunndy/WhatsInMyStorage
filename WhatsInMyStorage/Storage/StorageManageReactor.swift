//
//  StorageManageReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/12/13.
//

import UIKit
import ReactorKit
import RxDataSources

class StorageManageReactor: Reactor {
    
    enum Action {
        /// viewDidLoad, Refresh
        case refresh
        /// itemMoved
        case moveTask(IndexPath, IndexPath)
        /// itemDeleted
        case deleteTask(IndexPath)
        /// add
        case openAddPopup
        case addTask(MyStorageSectionData)
        /// edit
        case editTask(Bool)
        /// expand / unexpand Cells
        case expandSectionRows(Int)
        /// cell Action
        case cellAddTask(IndexPath, Int)
    }

    enum Mutation {
        /// refresh, add, move
        case setStorages([MyStorageSectionData])
        /// edit
        case editTask(Bool)
        case openAddPopup
        /// expand / unexpand Cells
        case setExpandedSectionSet(Set<Int>)
        case reloadSection(Int)
        /// Cell Action
//        case reloadRow(IndexPath)
    }
    
    struct State {
        @Pulse var isEditing: Bool = false
        @Pulse var storages: [MyStorageSectionData]
        @Pulse var openPopup: Void = ()
        @Pulse var expandedSectionSet = Set<Int>()
        @Pulse var reloadSection: Int = 0
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(storages: [MyStorageSectionData(header: "", items: [StorageData]())])
    }
    
    /// Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return Observable.concat([
                self.getStorageData(page: 1)
                    .map { Mutation.setStorages($0) }
            ])
        case .addTask(let addedSectionData):
            return Observable.concat([
                self.addStorageData(addedData: addedSectionData)
                    .map { Mutation.setStorages($0)}
            ])
        case .editTask(let isEditing):
            return Observable.concat([
                Observable.just(Mutation.editTask(isEditing))
            ])
        case .openAddPopup:
            return Observable.concat([
                Observable.just(Mutation.openAddPopup)
            ])
        case .expandSectionRows(let section):
            return Observable.concat([
                self.setExpandedSectionSet(section: section)
                    .map { Mutation.setExpandedSectionSet($0) },
                
                Observable.just(Mutation.reloadSection(section)),
            ])
        case let .moveTask(sourceIndexPath, targetIndexPath):
            return Observable.concat([
                self.moveStorageData(sourceIndexPath: sourceIndexPath, targetIndexPath: targetIndexPath)
                    .map { Mutation.setStorages($0) }
            ])
        case .deleteTask(let indexPath):
            return Observable.concat([
                self.deleteStorageData(indexPath: indexPath)
                    .map { Mutation.setStorages($0) }
            ])
        case .cellAddTask(let indexPath, let quantity):
            return Observable.concat([
                self.changeStorageData(indexPath: indexPath, quantity: quantity)
                    .map { Mutation.setStorages($0) }
            ])
        }
    }
    
    /// Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStorages(let storages):
            newState.storages = storages
            break
        case .editTask(let isEditing):
            newState.isEditing = isEditing
        case .openAddPopup:
            newState.openPopup = ()
        case .setExpandedSectionSet(let expandSectionSet):
            newState.expandedSectionSet = expandSectionSet
        case .reloadSection(let section):
            newState.reloadSection = section
        }
        
        return newState
    }
}

extension StorageManageReactor {
    private func setExpandedSectionSet(section: Int) -> Observable<Set<Int>> {
        
        var set = self.currentState.expandedSectionSet
        
        if set.contains(section) {
            set.remove(section)
        } else {
            set.insert(section)
        }
        
        return Observable.just(set)
    }
    
    private func getStorageData(page: Int) -> Observable<[MyStorageSectionData]> {
        
        let storageData = [StorageData(product: "양파123", quantity: 1),
                           StorageData(product: "가공육23", quantity: 2),
                           StorageData(product: "토마토", quantity: 3),
                           StorageData(product: "소세지", quantity: 4),
                           StorageData(product: "소세지1232", quantity: 4),
                           StorageData(product: "소세지51253", quantity: 4),
                           StorageData(product: "소세지4123", quantity: 4),
                           StorageData(product: "소세지515", quantity: 4),
                           StorageData(product: "소세지1236", quantity: 4),
                           StorageData(product: "소세지1247", quantity: 4),
                           StorageData(product: "소세지815", quantity: 10)]
        
        let intialSectionData = [MyStorageSectionData(header: "핫도그",items: storageData)]
        
        return Observable.just(intialSectionData)
    }
    
    private func addStorageData(addedData: MyStorageSectionData) -> Observable<[MyStorageSectionData]> {
        
        var convertedStorageData = self.currentState.storages
        
        // 현재 있는 섹션인지 찾기
        if let idx = self.currentState.storages.firstIndex(where: { $0.header == addedData.header }) {
            
            // 있는 아이템인지도 찾기
            if let itemIdx = convertedStorageData[idx].items.firstIndex(where: { $0.product == addedData.items[0].product }) {
                convertedStorageData[idx].items[itemIdx].quantity += addedData.items[0].quantity
            } else {
                convertedStorageData[idx].items += addedData.items
            }
            
        } else {
            convertedStorageData.append(addedData)
        }
        
        return Observable.just(convertedStorageData)
    }
    
    private func moveStorageData(sourceIndexPath: IndexPath, targetIndexPath: IndexPath) -> Observable<[MyStorageSectionData]> {
        
        var sections = self.currentState.storages
        var sourceItems = sections[sourceIndexPath.section].items
        var destinationItems = sections[targetIndexPath.section].items
         
        if sourceIndexPath.section == targetIndexPath.section {
            destinationItems.insert(destinationItems.remove(at: sourceIndexPath.row),
                                    at: targetIndexPath.row)
            let destinationSection = MyStorageSectionData(original: sections[targetIndexPath.section], items: destinationItems)
            sections[sourceIndexPath.section] = destinationSection
        }
         
        return Observable.just(sections)
    }
    
    private func deleteStorageData(indexPath: IndexPath) -> Observable<[MyStorageSectionData]> {
        
        var sectionDataArray = self.currentState.storages
        
        // 현재 섹션
        var currentSection = sectionDataArray[indexPath.section]
        
        // 현재 섹션의 아이템 제거
        currentSection.items.remove(at: indexPath.row)
        
        // 섹션 업데이트!
        sectionDataArray[indexPath.section] = currentSection
        
        return Observable.just(sectionDataArray)
    }
    
    private func changeStorageData(indexPath: IndexPath, quantity: Int) -> Observable<[MyStorageSectionData]> {
        
        var sectionDataArray = self.currentState.storages
        
        // 현재 섹션
        var currentSection = sectionDataArray[indexPath.section]
        
        // 현재 섹션의 아이템 제거
        currentSection.items[indexPath.row].quantity = quantity
        
        // 섹션 업데이트!
        sectionDataArray[indexPath.section] = currentSection
        
        return Observable.just(sectionDataArray)
    }
}
