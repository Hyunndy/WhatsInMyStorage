//
//  GitHubSearchViewReactor.swift
//  GitHubSearch
//
//  Created by Suyeol Jeon on 13/05/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class ReactorKitPracticeReactor: Reactor {
    
    enum Action {
        case updateQuery(String?)
        case loadNextPage
        
        static func isUpdateQueryAction(_ action: ReactorKitPracticeReactor.Action) -> Bool {
            if case .updateQuery = action {
                return true
            } else {
                return false
            }
        }
    }
    
    enum Action2 {
        /// searchBar의 rx.text에 걸려있는 Action
        case updateQuery(String?)
    }
    
    /*
     View -> Action -> Mutate -> Reduce -> State
     에서 Action -> State로 바꾸기 위해 필요한 각 Action에 맞는 Mutation들을 정의
     */
    enum Mutation {
        /// 현재 State의 Query를 세팅한다.
        case setQuery(String?)
        /// URLsession.rx.json에서 Observable<repos: [String], nextPage: Int>를 방출한다.
        /// 그럼 그걸! 받아서 Mutation.setRepos(repose, nextPage)로 넣어준다!
        case setRepos([String], nextPage: Int?)
        
        case appendRepos([String], nextPage: Int?)
        case setLoadingNextPage(Bool)
    }
    
    struct State {
        var query: String?
        var repos: [String] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    let initialState = State()
    
    /*
     View -> Action -> Mutate -> Reduce -> State
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
            /* searchBar.rx.text의 Action */
        case let .updateQuery(query):
            return Observable.concat([
                
                // 1) set current state's query (.setQuery)
                Observable.just(Mutation.setQuery(query)),
                
                /*
                 2) call API and set repos (.setRepos)
                 search 함수에서 Observable<repos: [String], nextPage: Int>를 리턴한다!!!
                 */
                self.search(query: query, page: 1)
                
                /*
                 cancel previous request when the new `.updateQuery` action is fired
                 take(unti: trigger) 트리거가 Next이벤트를 방출하는 순간 원본 Observable의 Complete가 불린다.
                 
                 즉, 현재 Query로 API 통신을 하던 도중 새로운 searchBar.rx.text의 Action, 즉 새로운 isUpdateQuryAction이 방출될 때 까지 방출한다리.
                 */
                    .take(until: self.action.filter(Action.isUpdateQueryAction))
                /*
                 State로 바꿔주기 위해!
                 Mutation의 setRepose case에 넣어준다.
                 */
                    .map { Mutation.setRepos($0, nextPage: $1) },
            ])
            
        case .loadNextPage:
            guard !self.currentState.isLoadingNextPage else { return Observable.empty() } // prevent from multiple requests
            guard let page = self.currentState.nextPage else { return Observable.empty() }
            return Observable.concat([
                // 1) set loading status to true
                Observable.just(Mutation.setLoadingNextPage(true)),
                
                // 2) call API and append repos
                self.search(query: self.currentState.query, page: page)
                    .take(until: self.action.filter(Action.isUpdateQueryAction))
                    .map { Mutation.appendRepos($0, nextPage: $1) },
                
                // 3) set loading status to false
                Observable.just(Mutation.setLoadingNextPage(false)),
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState
            
        case let .setRepos(repos, nextPage):
            var newState = state
            newState.repos = repos
            newState.nextPage = nextPage
            return newState
            
        case let .appendRepos(repos, nextPage):
            var newState = state
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
            return newState
            
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        }
    }
    
    private func url(for query: String?, page: Int) -> URL? {
        guard let query = query, !query.isEmpty else { return nil }
        return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
    }
    
    /* URLSession으로 통신해서 [repo들의 주소], nextPage를 방출한다. */
    private func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
        let emptyResult: ([String], Int?) = ([], nil)
        
        guard let url = self.url(for: query, page: page) else { return .just(emptyResult) }
        
        /*
         Observable sequence of response JSON for GET request with `URL`.
          
         Performing of request starts after observer is subscribed and not after invoking this method.
         */
        return URLSession.shared.rx.json(url: url)
            .map { json -> ([String], Int?) in
                
                guard let dict = json as? [String: Any] else { return emptyResult }
                guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
                let repos = items.compactMap { $0["full_name"] as? String }
                let nextPage = repos.isEmpty ? nil : page + 1
                return (repos, nextPage)
            }
            .do(onError: { error in
                if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                    print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
                }
            })
                .catchAndReturn(emptyResult)
                }
}

extension ReactorKitPracticeReactor.Action {
    
}
