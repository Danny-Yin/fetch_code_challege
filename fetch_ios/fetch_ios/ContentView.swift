//
//  ContentView.swift
//  fetch_ios
//
//  Created by Jiajie Yin on 5/31/24.
//

import SwiftUI

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct ContentView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var errorMessage: IdentifiableString?
    
    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipeID: recipe.idMeal)) {
                    Text(recipe.strMeal)
                }
            }
            .navigationTitle("Desserts")
            .onAppear(perform: fetchDesserts)
            .alert(item: $errorMessage) { message in
                Alert(title: Text("Error"), message: Text(message.value), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func fetchDesserts() {
        isLoading = true
        errorMessage = nil
        
        RecipeService().fetchDesserts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    self.recipes = recipes.sorted { $0.strMeal < $1.strMeal }
                case .failure(let error):
                    self.errorMessage = IdentifiableString(value: error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RecipeDetailView: View {
    let recipeID: String
    @State private var recipeDetail: RecipeDetail?
    @State private var isLoading = false
    @State private var errorMessage: IdentifiableString?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let recipeDetail = recipeDetail {
                ScrollView {
                    Text(recipeDetail.strMeal)
                        .font(.largeTitle)
                        .padding()
                    Text(recipeDetail.strInstructions)
                        .padding()
                    VStack(alignment: .leading) {
                        ForEach(recipeDetail.ingredients, id: \.self) { ingredient in
                            Text(ingredient)
                        }
                    }
                    .padding()
                }
            } else if let errorMessage = errorMessage {
                Text(errorMessage.value)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Recipe Details")
        .onAppear(perform: fetchRecipeDetail)
    }
    
    private func fetchRecipeDetail() {
        isLoading = true
        errorMessage = nil
        
        RecipeService().fetchRecipeDetail(id: recipeID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let detail):
                    self.recipeDetail = detail
                case .failure(let error):
                    self.errorMessage = IdentifiableString(value: error.localizedDescription)
                }
            }
        }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipeID: "52772")
    }
}

#Preview {
    ContentView()
}
