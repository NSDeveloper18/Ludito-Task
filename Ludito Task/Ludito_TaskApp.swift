//
//  Ludito_TaskApp.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 06/05/25.
//

import SwiftUI
import YandexMapsMobile

@main
struct Ludito_TaskApp: App {
    let persistenceController = PersistenceController.shared
    init() {
        YMKMapKit.setApiKey("522fb9ba-acc3-4c2a-ad64-371448cace44")
    }
    var body: some Scene {
        WindowGroup {
            ViewController()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
