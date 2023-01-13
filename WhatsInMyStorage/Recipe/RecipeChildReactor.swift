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
    }
    
    struct State {
        var recipeArray: [Recipe]
    }
    
    var initialState: State
    
    unowned var recipeRelay: PublishRelay<[Recipe]>!
    
    init(recipeRelay: PublishRelay<[Recipe]>) {
        self.initialState = State(recipeArray: [Recipe]())
        self.recipeRelay = recipeRelay
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .refresh(let array):
            newState.recipeArray = array
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge(mutation, recipeRelay.map { Mutation.refresh($0) })
    }
}
