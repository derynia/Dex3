//
//  FetchedPokemon.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 22/02/2025.
//
import Foundation


struct FetchedPokemon {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defence: Int16
    let specialAttack: Int16
    let specialDefence: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: CodingKey {
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case sprite = "frontDefauls"
            case shiny = "frontShiny"
            
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}
