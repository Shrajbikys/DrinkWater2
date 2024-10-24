//
//  DrinkWaterApp.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 30.05.2024.
//

import SwiftUI
import SwiftData
import AppMetricaCore

@main
struct DrinkWaterApp: App {
    @State private var networkMonitor = NetworkMonitor()
    @State private var purchases: PurchaseManager = .init()
    private let appMetricaConfiguration = AppMetricaConfiguration(apiKey: "57af5786-bb55-453d-b5c3-13b63b49fc6b")
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Profile.self,
            DataDrinking.self,
            DataDrinkingOfTheDay.self,
            Reminder.self,
            DataWeight.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    if networkMonitor.isConnected {
                        await fetchProducts()
                    }
                }
                .onAppear {
                    if networkMonitor.isConnected {
                        AppMetrica.activate(with: appMetricaConfiguration!)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .environment(purchases)
    }
}

extension DrinkWaterApp {
    private func fetchProducts() async {
        do {
            try await purchases.configure()
        } catch {
            print(error)
        }
    }
}
