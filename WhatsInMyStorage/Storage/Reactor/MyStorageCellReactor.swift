//
//  MyStorageCellReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/12.
//

import ReactorKit
import Foundation

final class MyStorageCellReactor: Reactor {
    
    // Action is an user interaction
    enum Action {
        case decrease
        case increase
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case decreaseValue
        case increaseValue
    }
    
    // State is current View State
    struct State {
        var quantity: Int
    }

    var initialState: State
    
    init() {
        self.initialState = State(quantity: 0) // start from 0
    }
    
    /*
     Action -> Mutation
     
     Action이 들어오면 mutate 함수를 통해 Observable<Mutation>을 리턴하고, 이 Mutation은 state를 변경시킨다.
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .decrease:
            return Observable.concat([
                Observable.just(Mutation.decreaseValue),
            ])
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.increaseValue),
            ])
        }
    }
    
    /*
     Mutation -> State
     
     mutate에서 방출된 Mutation은 reduce 메서드를 통해 state를 변경시킨다.
     */
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .decreaseValue:
            state.quantity -= 1
        case .increaseValue:
            state.quantity += 1
        }
        
        return state
    }
}
