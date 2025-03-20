//
//  ContentView.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 21/02/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    @State private var selectedType: String = "All"

    var uniqueTypes: [String] {
        var typesSet = Set(pokedex.flatMap { $0.types }).sorted()
        typesSet.insert("All", at: 0)
        
        return typesSet
    }

    let fetcher = FetchService()
    
    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            (selectedType == "All" || pokemon.types.contains(selectedType)) &&
            (!filterByFavorites || pokemon.favorite) &&
            (searchText.isEmpty || pokemon.name.localizedStandardContains(searchText))
        }
    }

    var body: some View {
        if (pokedex.isEmpty) {
            ContentUnavailableView {
                Label("No pokemon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokemon yet \nFetch some pokemon to get started.")
            } actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            NavigationStack {
                List {
                    Section  {
                        ForEach((try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                Button {
                                    pokemon.showShiny.toggle()
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print(error)
                                    }
                                } label: {
                                    if pokemon.sprite == nil {
                                        AsyncImage(url: pokemon.showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 100)
                                    } else {
                                        let currentImage = pokemon.showShiny ? pokemon.shinyImage : pokemon.spriteImage
                                        currentImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if (pokemon.favorite) {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                        
                                    }
                                    HStack {
                                        ForEach(pokemon.types, id: \.self) { type in
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
                            .swipeActions(edge: .leading) {
                                Button(
                                    pokemon.favorite ? "Remove from favorites" : "Add to favorites",
                                    systemImage: "star"
                                ) {
                                    pokemon.favorite.toggle()
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if pokedex.count < 151 {
                            ContentUnavailableView {
                                Label("Mission Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the Pokemon")
                            } actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt: "Find a pokemon")
                .autocorrectionDisabled(true)
                .animation(.default, value: searchText)
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail(pokemon: pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
                        } label: {
                            Label("Filter by favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker("Filter", selection: $selectedType.animation()) {
                                ForEach(uniqueTypes, id: \.self) { type in
                                    Text(type.capitalized).tag(type as String?)
                                }
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }

        }
    }
    
    private func getPokemon(from id: Int) {
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    modelContext.insert(fetchedPokemon)
                } catch {
                    print(error)
                }
            }
            
            storeSprites()
        }
    }
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in pokedex {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    
                    try modelContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(PersistenceController.preview)
}
