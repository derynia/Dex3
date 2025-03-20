//
//  PokemonDetail.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 18/03/2025.
//

import SwiftUI

struct PokemonSprites: View {
    @Environment(\.modelContext) private var modelContext
    var pokemon: Pokemon
    
    @State private var selectedTab: URL
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        _selectedTab = State(initialValue: pokemon.allSprites.first ?? URL(string: "https://example.com")!)
    }
    
    var body: some View {
        ZStack {
            Image(pokemon.background)
                .resizable()
                .scaledToFit()
                .shadow(color: .black, radius: 6)
            
            TabView(selection: $selectedTab) {
                ForEach(pokemon.allSprites, id: \.self) { spriteUrl in
                    AsyncImage(url: spriteUrl) { image in
                        image
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .tabViewStyle(.page)
//            .frame(width: geo.size.width/1.2, height: geo.size.height / 1.7)
            .clipShape(.rect(cornerRadius: 25))
            .padding(.top, 60)
        }
        .navigationTitle(pokemon.name.capitalized)
    }
}

#Preview {
    NavigationStack {
        PokemonSprites(pokemon: PersistenceController.previewPokemon)
    }
}
