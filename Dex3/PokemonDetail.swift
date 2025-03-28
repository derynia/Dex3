//
//  PokemonDetail.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 18/03/2025.
//

import SwiftUI

struct PokemonDetail: View {
    @Environment(\.modelContext) private var modelContext
    var pokemon: Pokemon
    
    @State private var showShiny: Bool = false
        
    var body: some View {
        ScrollView {
            NavigationLink(destination: PokemonSprites(pokemon: pokemon)) {
                ZStack {
                    Image(pokemon.background)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 6)
                    if (pokemon.sprite == nil || pokemon.shiny == nil) {
                        AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                            image
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .padding(.top, 50)
                                .shadow(color: .black, radius: 6)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    }
                }
            }
            
            HStack {
                ForEach(pokemon.types, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                }
                .padding(.top)
                .padding(.horizontal, 10)
                
                Spacer()
                
                Button() {
                    pokemon.favorite.toggle()
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
                .padding(.horizontal, 10)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(pokemon.moves, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .shadow(color: .white, radius: 1)
                            .padding(.vertical, 7)
                            .padding(.horizontal)
                            .background(.green)
                            .clipShape(.capsule)
                    }
                    .padding(.top)
                    .padding(.horizontal, 5)
                }
            }
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail(pokemon: PersistenceController.previewPokemon)
    }
}
