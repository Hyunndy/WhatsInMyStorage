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
        case insertStorage([MyStorageSectionData])
    }
    
    /// 실제 해야될 작업
    enum Mutation {
        case setIndicator(Bool)
        case setStorageData([MyStorageSectionData])
//        case appendStorageData([StorageData], nextPage: Int?)
    }
    
    /// 실제 View에 전달될 정보
    struct State {
        @Pulse var isPlayIndicator: Bool?
        @Pulse var storageData: [MyStorageSectionData]?
//        var nextPage: Int?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(isPlayIndicator: false, storageData: nil)
        _ = self.state // add this line to create a state immediately
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
        case let .insertStorage(currentStorage):
            return Observable.concat([
                
                // 1) 데이터 집어넣기
                self.addStorageData(currentData: currentStorage)
                    .map { Mutation.setStorageData($0) },
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
//            newState.nextPage = 2
//        case .appendStorageData(let data, let nextPage):
//            newState.storageData?.append(data)
//            newState =
        }
    }
    
    
    private func getStorageData(page: Int) -> Observable<[MyStorageSectionData]> {
        
        let storageData = [StorageData(product: "양파", quantity: 1),
                           StorageData(product: "가공육", quantity: 2),
                           StorageData(product: "토마토", quantity: 3),
                           StorageData(product: "소세지", quantity: 4)]
         
        var intialSectionData = [MyStorageSectionData(items: storageData)]
        
        return Observable.just(intialSectionData)
    }
    
    private func addStorageData(currentData: [MyStorageSectionData]) -> Observable<[MyStorageSectionData]> {
        
        var convertedStorageData = currentData
        
        let addStorageData = [StorageData(product: "핫도그빵", quantity: 10)]
        
        convertedStorageData[0].items.append(contentsOf: addStorageData)
        
        return Observable.just(convertedStorageData)
    }
}
