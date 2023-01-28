//
//  RecipeDetailModel.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2023/01/28.
//

import Foundation

/*
 "data": [
     {
         "id": 1,
         "attributes": {
             "name": "윌리도그",
             "price": 5000,
             "createdAt": "2023-01-28T13:24:15.778Z",
             "updatedAt": "2023-01-28T13:24:31.447Z",
             "publishedAt": "2023-01-28T13:24:31.445Z"
         }
     }
 ],
 */

struct StrapiRecipeDetailContainerModel: Decodable {
    var data: [RecipeDetailModel]
}

//struct StrapiRecipeAttributeModel: Decodable {
//    var id: Int
//    var attributes: RecipeDetailModel
//}

struct RecipeDetailModel: Decodable {
    
    var id: Int
    var name: String
    var price: Int
    //    var imageUrl: String
    //    var ingredients: [String]
    //    var recipeStep: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case attributes
        
        enum NestedCodingKeys: String, CodingKey {
            case name
            case price
        }
        
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try rootContainer.decode(Int.self, forKey: .id)
        
        let attirubuteContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.NestedCodingKeys.self, forKey: .attributes)
        self.name = try attirubuteContainer.decode(String.self, forKey: .name)
        self.price = try attirubuteContainer.decode(Int.self, forKey: .price)
    }
}
