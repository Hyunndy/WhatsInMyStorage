//
//  RecipeDetailViewModel.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/29.
//

import Foundation
import RxSwift
import RxRelay

class RecipeDetailViewModel {
    
    let relay: BehaviorRelay<[RecipeDetailModel]?> = BehaviorRelay(value: nil)
    
    private func url() -> URL {
        return URL(string: "http://192.168.45.137:1337/api/recipe-details")!
    }
    
    func fetch() {
        
        Task {
            let recipes = try await getRecipeData()
            if let recipes {
                self.relay.accept([recipes])
            }
        
            
            
        }
        
    }
    
    func getRecipeData() async throws -> RecipeDetailModel? {
        
        let (data, response) = try await URLSession.shared.data(from: self.url())
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIError.invaild }
        
        do {
            let recipe = try JSONDecoder().decode(StrapiRecipeDetailContainerModel.self, from: data)
            return recipe.data[0]
            
        } catch {
            
            print(error)
            
            return nil
        }
    }
}
