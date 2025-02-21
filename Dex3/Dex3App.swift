//
//  Dex3App.swift
//  Dex3
//
//  Created by Oleksii Shamarin on 21/02/2025.
//

import SwiftUI

@main
struct Dex3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
