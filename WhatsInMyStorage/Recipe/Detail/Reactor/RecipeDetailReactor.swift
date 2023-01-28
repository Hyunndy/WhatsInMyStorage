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
            
            Task {
                print("fetch 들어왔음")
                let model = try? await self.fetch()
                return Observable.just(Mutation.fetch(model))
            }
        default:
            break
        }
        
        return Observable.just(Mutation.nothing)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = self.initialState
        
        switch mutation {
        case .fetch(let data):
            state.recipeDetail = data
        default:
            break
        }
        
        return state
    }
    
    private func url() -> URL {
        return URL(string: "http://192.168.45.137:1337/api/recipe-details")!
    }
    
    // MARK: URLSession + async await 쓴 버전
    func fetch() async throws -> RecipeDetailModel? {
        
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
            
            print("레시피 \(recipe)")
            
            return recipe.data[0].attributes
            
        } catch {
            
            print(error)
            
            return nil
        }
    }
}
