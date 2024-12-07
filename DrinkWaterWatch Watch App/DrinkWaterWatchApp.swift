//
//  DrinkWaterWatchApp.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import SwiftUI

@main
struct DrinkWaterWatch_Watch_AppApp: App {
    @StateObject private var drinkProvider = WatchDrinkDataProvider()
    @State private var watchSessionManager = WatchSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(watchSessionManager)
        }
        .environmentObject(drinkProvider)
    }
}
