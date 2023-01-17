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
        case search(String?)
    }
    
    struct State {
        var recipeArray: [Recipe]
    }
    
    var initialState: State
    
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
            // 리프레시 후에는 initaliState에 저장해둔다.
            self.initialState.recipeArray = array
            newState.recipeArray = array
        case .search(let query):
            if let query, query.isEmpty == false {
                newState.recipeArray = initialState.recipeArray.filter { $0.name.contains(query) }
            } else {
                newState.recipeArray = initialState.recipeArray
            }
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
            case .search(let query):
                return Observable.just(.search(query))
            default:
                return Observable.just(.refresh([Recipe]()))
            }
        }
        
        return Observable.merge(mutation, eventMutation)
    }
}
