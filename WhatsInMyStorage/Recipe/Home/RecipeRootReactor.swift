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
    // 찾기
    case search(String?)
}

protocol RecipeDataProtocol {
    var event: PublishRelay<UserEvent> { get }
    
    func updateRecipeData(data: [Recipe])
    func addRecipe(data: Recipe)
    func searchRecipe(query: String?)
}

class RecipeDataService: RecipeDataProtocol {
    let event = PublishRelay<UserEvent>()

    func updateRecipeData(data: [Recipe]) {
        event.accept(.refresh(data))
    }
    
    func addRecipe(data: Recipe) {
        event.accept(.add(data))
    }
    
    func searchRecipe(query: String?) {
        event.accept(.search(query))
    }
}

class RecipeRootReactor: Reactor {
    
    enum Action {
        case refresh
        case search(String?)
    }
    
    enum Mutation {
        case updateRecipeArray(Bool)
        case playIndicator(Bool)
    }
    
    struct State {
        // 인디케이터 on/off
        var indicator: Bool = false
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
        case .search(let query):
            return Observable.concat([
                Observable.just(Mutation.playIndicator(true)),
                self.search(query: query).map { Mutation.playIndicator($0) }
            ])
        }
    }
    
    /// 데이터 받아오고 성공/실패를 리턴한다.
    private func fetchData() -> Observable<Bool> {
        
        var recipeArray = [Recipe(name: "윌리도그2", price: 6500, image: "kikiCake", sortBy: "음료"), Recipe(name: "칠리도그2", price: 7000, image: "kikiCake", sortBy: "디저트"), Recipe(name: "오레오크로플2", price: 7000, image: "kikiCake", sortBy: "음료")]
        
        // 데이터 받아오기~
        self.service.updateRecipeData(data: recipeArray)
        
        return Observable.just(true)
    }
    
    // 검색
    private func search(query: String?) -> Observable<Bool> {
        
        // 검색 때리기!
        self.service.searchRecipe(query: query)
        
        return Observable.just(false)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateRecipeArray(let success):
            newState.refreshSuccess = success
        case .playIndicator(let doPlayIndicator):
            newState.indicator = doPlayIndicator
        }
        
        return newState
    }
}
