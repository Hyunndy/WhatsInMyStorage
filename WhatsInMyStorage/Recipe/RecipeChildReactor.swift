//
//  RecipeReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/12.
//

import Foundation
import RxRelay
import RxSwift
import ReactorKit

class RecipeReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        case refresh([Recipe])
        case add(Recipe)
    }
    
    struct State {
        var recipeArray: [Recipe]
    }
    
    var initialState: State
    
//    unowned var recipeRelay: PublishRelay<[Recipe]>!
//
//    init(recipeRelay: PublishRelay<[Recipe]>) {
//        self.initialState = State(recipeArray: [Recipe]())
//        self.recipeRelay = recipeRelay
//    }
    
    var service: RecipeDataProtocol
    
    init(service: RecipeDataProtocol) {
        self.initialState = State(recipeArray: [Recipe]())
        self.service = service
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .refresh(let array):
            newState.recipeArray = array
        default:
            break
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = service.event.flatMap { event -> Observable<Mutation> in
            switch event {
            case .refresh(let recipeArray):
                return Observable.just(.refresh(recipeArray))
            case .add(let recipe):
                return Observable.just(.add(recipe))
            }
        }
        
        return Observable.merge(mutation, eventMutation)
        
//        return Observable.merge(mutation, recipeRelay.map { Mutation.refresh($0) })
    }
}
