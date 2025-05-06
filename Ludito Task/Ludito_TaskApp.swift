//
//  Ludito_TaskApp.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 06/05/25.
//

import SwiftUI

@main
struct Ludito_TaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
