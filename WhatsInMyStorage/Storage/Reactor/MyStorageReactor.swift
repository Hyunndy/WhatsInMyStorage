//
//  MyStorageReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/04.
//

import Foundation
import ReactorKit

/*
 재고관리 VC의 Reactor
 
 필요한 액션
    - 인디케이터 Start/Stop
    - 테이블 뷰 로딩
    - 바뀐 데이터 저장(?)
 */
final class MyStorageReactor: Reactor {
    
    /// 작업에 대한 명칭
    enum Action {
        case fetch
        case newinsertStorage([MyStorageSectionData], MyStorageSectionData)
        case editing(Bool)
        case add
        case confirm([MyStorageSectionData])
    }
    
    /// 실제 해야될 작업
    enum Mutation {
        case setIndicator(Bool)
        case setStorageData([MyStorageSectionData])
        case setEditing(Bool)
        case openPopup
        case confirm
//        case appendStorageData([StorageData], nextPage: Int?)
    }
    
    /// 실제 View에 전달될 정보
    struct State {
        @Pulse var isPlayIndicator: Bool?
        @Pulse var storageData: [MyStorageSectionData]?
        @Pulse var isEditing: Bool = false
        @Pulse var openPopup: Void = ()
        @Pulse var confirm: Void = ()
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(isPlayIndicator: false, storageData: nil)
//        _ = self.state // add this line to create a state immediately
    }
    
    /// Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return Observable.concat([
                // 1) 인디케이터 시작
                Observable.just(Mutation.setIndicator(true)),
                
                // 2) API 통신
                self.getStorageData(page: 1)
                    .delay(.seconds(2), scheduler: MainScheduler.instance)
                    .map { Mutation.setStorageData($0) },
                
                // 3) 인디케이터 멈춤
                Observable.just(Mutation.setIndicator(false))
            ])
        case let .newinsertStorage(currentStorage, addedStorage):
            return Observable.concat([
                
                // 1) 데이터 집어넣기
                self.addStorageData(currentData: currentStorage, addedData: addedStorage)
                    .map { Mutation.setStorageData($0) },
            ])
        case .editing(let isEditing):
            return Observable.concat([
                Observable.just(Mutation.setEditing(isEditing))
            ])
        case .add:
            return Observable.concat([
                Observable.just(Mutation.openPopup)
            ])
        case let .confirm(currentStorage):
            return Observable.concat([
                
                // 1) 데이터 저장하기
                Observable.just(Mutation.confirm)
            ])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIndicator(let isPlay):
            newState.isPlayIndicator = isPlay
            return newState
        case .setStorageData(let data):
            newState.storageData = data
            return newState
        case .setEditing(let isEditing):
            newState.isEditing = isEditing
            return newState
        case .openPopup:
            newState.openPopup = ()
            return newState
        case .confirm:
            newState.confirm = ()
            return newState
        }
    }
    
    
    private func getStorageData(page: Int) -> Observable<[MyStorageSectionData]> {
        
        let storageData = [StorageData(product: "양파", quantity: 1),
                           StorageData(product: "가공육", quantity: 2),
                           StorageData(product: "토마토", quantity: 3),
                           StorageData(product: "소세지", quantity: 4)]
         
        let intialSectionData = [MyStorageSectionData(header: "핫도그",items: storageData)]
        
        return Observable.just(intialSectionData)
    }
    
    private func addStorageData(currentData: [MyStorageSectionData], addedData: MyStorageSectionData) -> Observable<[MyStorageSectionData]> {
        
        var convertedStorageData = currentData
        
        // 현재 있는 섹션인지 찾기
        if let idx = currentData.firstIndex(where: { $0.header == addedData.header }) {
            
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
}
