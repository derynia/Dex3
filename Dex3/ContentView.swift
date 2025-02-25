//
//  ContentView.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 21/02/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    ) private var pokedex
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        if (!searchText.isEmpty) {
            predicates.append(
                NSPredicate(format: "name contains[c] %@", searchText)
            )
        }
        
        if (filterByFavorites) {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(pokemon.name!.capitalized)
                                    .fontWeight(.bold)
                                
                                if (pokemon.favorite) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }

                            }
                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(Color(type.capitalized))
                                        .clipShape(.capsule)
                                }
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchText, prompt: "Find a pokemon")
            .autocorrectionDisabled(true)
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavorites) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                Text(pokemon.name ?? "No name")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        filterByFavorites.toggle()
                    } label: {
                        Label("Filter by favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
        }
    }
    
    private func getPokemon() {
        Task {
            for id in 1..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    let pokemon = Pokemon(context: viewContext)
                    
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defence = fetchedPokemon.defence
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefence = fetchedPokemon.specialDefence
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    if pokemon.id % 2 == 0 {
                        pokemon.favorite = true
                    }
                    
                    try viewContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
