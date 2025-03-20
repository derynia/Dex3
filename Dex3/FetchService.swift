//
//  FetchService.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 24/02/2025.
//

import Foundation

struct FetchService {
    enum FetchError: Error {
        case badResponse
        
    }
    
    private let baseURL: URL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        let fetchURL = baseURL.appendingPathComponent(String(id))
        
        let (data,response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        print("Fetched: \(pokemon.id): \(pokemon.name.capitalized)")
        
        return pokemon
    }
}
