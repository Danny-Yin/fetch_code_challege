import Foundation

struct Recipe: Decodable, Identifiable {
    let idMeal: String
    let strMeal: String
    
    var id: String {
        idMeal
    }
}

struct RecipeDetail: Decodable {
    let strMeal: String
    let strInstructions: String
    let ingredients: [String]
    
    enum CodingKeys: String, CodingKey {
        case strMeal, strInstructions
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        
        var ingredientsArray: [String] = []
        for index in 1...5 {
            let ingredientKey = CodingKeys(stringValue: "strIngredient\(index)")!
            let measureKey = CodingKeys(stringValue: "strMeasure\(index)")!
            if let ingredient = try? container.decode(String.self, forKey: ingredientKey),
               let measure = try? container.decode(String.self, forKey: measureKey),
               !ingredient.isEmpty, !measure.isEmpty {
                ingredientsArray.append("\(measure) \(ingredient)")
            }
        }
        ingredients = ingredientsArray.filter { !$0.isEmpty }
    }
    
    init(strMeal: String, strInstructions: String, ingredients: [String]) {
        self.strMeal = strMeal
        self.strInstructions = strInstructions
        self.ingredients = ingredients
    }
}


class RecipeService {
    private let baseURL = "https://themealdb.com/api/json/v1/1/"
    
    func fetchDesserts(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let url = URL(string: baseURL + "filter.php?c=Dessert")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [Recipe]].self, from: data)
                let recipes = (decodedResponse["meals"] ?? []).filter { !$0.strMeal.isEmpty }
                completion(.success(recipes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRecipeDetail(id: String, completion: @escaping (Result<RecipeDetail, Error>) -> Void) {
        let url = URL(string: baseURL + "lookup.php?i=\(id)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [RecipeDetail]].self, from: data)
                if let recipeDetail = decodedResponse["meals"]?.first {
                    // filter out any null or empty values
                    let filteredIngredients = recipeDetail.ingredients.filter { !$0.isEmpty }
                    let filteredRecipeDetail = RecipeDetail(strMeal: recipeDetail.strMeal, strInstructions: recipeDetail.strInstructions, ingredients: filteredIngredients)
                    completion(.success(filteredRecipeDetail))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recipe detail found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
