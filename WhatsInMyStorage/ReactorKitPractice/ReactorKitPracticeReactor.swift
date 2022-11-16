//
//  ReactorKitPracticeReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/15.
//

import ReactorKit
import Foundation
import RxSwift
import RxCocoa

class ReactorKitPracticeReactor: Reactor {
    var initialState: State = State()
    
    // from ViewController
    enum Action {
        case loadNextPage
        case updateQuary(String?)
        
        static func isUpdateQueryAction(_ action: ReactorKitPracticeReactor.Action) -> Bool {
            if case .updateQuary = action {
                return true
            } else {
                return false
            }
        }
    }
    
    // Action -> State
    enum Mutation {
        case setQuery(String?) // 검색
        case setRepos([String], nextPage: Int?) // 테이블 뷰에 레포 세팅
        case appendRepos([String], nextPage: Int?) // 레포들 넣기?
        case setLoadingNextPage(Bool) // 다음 페이지 로딩
    }
    
    // View에 보내기
    struct State {
        var query: String?
        var repose: [String] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        // 다음 페이지 로딩
        case .loadNextPage:
            // prevent from multiple requests
            guard self.currentState.isLoadingNextPage == false else { return Observable.empty() }
            // state에 들어있는 다음 페이지
            guard let page = self.currentState.nextPage else { return Observable.empty() }
            
            return Observable.concat([
                
                // 1) set loading State to true
                Observable.just(Mutation.setLoadingNextPage(true)),
                
                // 와 이 코드 진짜 이해 못하겠다.......
                // 2) call API and append repos
                self.search(query: self.currentState.query, page: page)
                    .take(until: self.action.filter(Action.isUpdateQueryAction))
                    .map { Mutation.appendRepos($0, nextPage: $1)},
                
                
                // 3) set loading Status to false
                Observable.just(Mutation.setLoadingNextPage(false)),
            ])
            
            
        // 검색 업데이트 -> 이 문법은 뭐지????
        case let .updateQuary(query):
            
            return Observable.concat([
                
                // 1) set current state's query(.setQuery)
                Observable.just(Mutation.setQuery(query)),
            
                // 와 이코드 진짜 이해 못하겠다..........2
                // 2) call API and set repos (.setRepos)
                self.search(query: query, page: 1)
                    // cancel previous request when the new '.udpateQUery' action is fired
                    .take(until: self.action.filter(Action.isUpdateQueryAction))
                    .map { Mutation.setRepos($0, nextPage: $1)}
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
            newState.repose = repos
            newState.nextPage = nextPage
            return newState
            
        case let .appendRepos(repos, nextPage):
            var newState = state
            newState.repose.append(contentsOf: repos)
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

    
    private func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
        
        let emptyResult: ([String], Int?) = ([], nil)
        
        guard let url = self.url(for: query, page: page) else { return .just(emptyResult)}
        
        // RxSwift JSON
        return URLSession.shared.rx.json(url: url)
            .map { json -> ([String], Int?) in
                
                guard let dic = json as? [String: Any] else { return emptyResult }
                guard let items = dic["items"] as? [[String: Any]] else { return emptyResult}
                
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
