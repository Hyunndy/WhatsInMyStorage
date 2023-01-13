//
//  RecipeRootReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/13.
//

import Foundation
import RxRelay
import RxSwift
import ReactorKit

enum UserEvent {
    // 초기, 새로고침
    case refresh([Recipe])
    // 더하기
    case add(Recipe)
}

protocol RecipeDataProtocol {
    var event: PublishRelay<UserEvent> { get }
    
    func updateRecipeData(data: [Recipe])// -> Observable<[Recipe]>
    func addRecipe(data: Recipe)// -> Observable<Recipe>
}

class RecipeDataService: RecipeDataProtocol {
    let event = PublishRelay<UserEvent>()

    func updateRecipeData(data: [Recipe]) {
        event.accept(.refresh(data))
    }
    
    func addRecipe(data: Recipe) {
        event.accept(.add(data))
    }
}

class RecipeRootReactor: Reactor {
    
    /// child와 공유하는 Global State
    var recipeArray = PublishRelay<[Recipe]>()
    
    enum Action {
        case refresh
    }
    
    enum Mutation {
        case updateRecipeArray(Bool)
    }
    
    struct State {
        var refreshSuccess: Bool = false
    }
    
    var initialState: State
    let service: RecipeDataProtocol
    
    init(service: RecipeDataProtocol) {
        self.initialState = State()
        self.service = service
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return self.fetchData()
                .map { Mutation.updateRecipeArray($0) }
//            return self.fetchData()
//                .map { Mutation.updateRecipeArray($0) }
        }
    }
    
    /// 데이터 받아오고 성공/실패를 리턴한다.
    private func fetchData() -> Observable<Bool>{
        
        var recipeArray = [Recipe(name: "윌리도그2", price: 6500, image: "kikiCake", sortBy: "음료"), Recipe(name: "칠리도그2", price: 7000, image: "kikiCake", sortBy: "디저트"), Recipe(name: "오레오크로플2", price: 7000, image: "kikiCake", sortBy: "음료")]
        
        // 데이터 받아오기~
//        self.recipeArray.accept(recipeArray)
        self.service.updateRecipeData(data: recipeArray)
        
        return Observable.just(true)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateRecipeArray(let success):
            newState.refreshSuccess = success
        }
        
        return newState
    }
}


