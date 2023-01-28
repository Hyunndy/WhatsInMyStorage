//
//  RecipeDetailReactor.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/28.
//

import Foundation
import ReactorKit

class RecipeDetailReactor: Reactor {
    
    enum Action {
        case fetch
    }
    
    enum Mutation {
        case nothing
        case fetch(RecipeDetailModel?)
    }
    
    struct State {
        var recipeDetail: RecipeDetailModel?
    }
    
    var initialState = State(recipeDetail: nil)
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .fetch:
            
            Task(priority: .high) {
                return try await self.fetch()
            }
        }
        
        return Observable.just(Mutation.nothing)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = self.initialState
        
        switch mutation {
        case .fetch(let data):
            print("페치데이터: \(data)")
            state.recipeDetail = data
        default:
            print("두낫띵입니다.")
            break
        }
        
        return state
    }
    
    private func url() -> URL {
        return URL(string: "http://192.168.45.137:1337/api/recipe-details")!
    }
    
    func fetch2() -> Observable<RecipeDetailModel?> {
        return URLSession.shared.rx.data(request: URLRequest(url: self.url()))
            .map { json -> RecipeDetailModel? in
                let recipe = try JSONDecoder().decode(StrapiRecipeDetailContainerModel.self,    from: json)
//
                print(recipe.data[0])
                return recipe.data[0]
            }
    }
    
    // MARK: URLSession + async await 쓴 버전
    func fetch() async throws -> Observable<Mutation> {
        
        /*
         public func data(from url: URL) async throws -> (Data, URLResponse)
         */
        do {
            
            var a = URLRequest(url: self.url())
            a.httpMethod = "GET"
            a.httpBody = Data()
            
            let (data, response) = try await URLSession.shared.data(for: a)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIError.invaild }
            
            print("데이터 \(data)")
            
            let recipe = try JSONDecoder().decode(StrapiRecipeDetailContainerModel.self, from: data)
            
            print("레시피 \(recipe.data[0])")
            
            return Observable.just(Mutation.fetch(recipe.data[0]))
            
        } catch {
            
            print(error)
            
            return Observable.just(Mutation.fetch(nil))
        }
    }
}
