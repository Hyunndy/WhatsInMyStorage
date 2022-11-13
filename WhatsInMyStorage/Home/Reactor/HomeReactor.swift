//
//  HomeReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/06.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    
    enum Action {
        case homeInfo
    }
    
    enum Mutation {
        case updateHomeInfo(String)
    }
    
    struct State {
        var homeInfo: String
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(homeInfo: "")
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .homeInfo:
            return self.getAPI().map { Mutation.updateHomeInfo($0!) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case .updateHomeInfo(let storeName):
            state.homeInfo = storeName
        }
        
        return state

    }
    
    func getAPI() -> Observable<String?> {
        
        let url = URL(string: "https://baconipsum.com/api/?type=all-meat&paras=\(0)&start-with-lorem=1")!
        return URLSession.shared.rx.json(url: url)
            .map {
                guard let paragraph = $0 as? [String] else { return "" }
                
                print(paragraph[0])
                
                return "Kiki's Delivery Store"
                
            }
    }
}
