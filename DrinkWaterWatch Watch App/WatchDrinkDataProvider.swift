//
//  DrinkDataProvider.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 18.11.2024.
//

import Foundation

class WatchDrinkDataProvider: ObservableObject {
    @Published var drinks: [Drinks] = []
    private var localizedNameMap: [String: String] = [:]
    private var hydrationMap: [String: Double] = [:]

    init() {
        loadLocalizedDrinks()
    }

    private func loadLocalizedDrinks() {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let fileName = "Drinks_\(languageCode)"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Localization file for \(languageCode) not found, falling back to English.")
            return loadFallbackDrinks()
        }

        do {
            let data = try Data(contentsOf: url)
            let localizedDrinks = try JSONDecoder().decode([Drinks].self, from: data)
            DispatchQueue.main.async {
                self.drinks = localizedDrinks
                self.updateHydratioAndLocalizedNamenMap()
            }
        } catch {
            print("Error loading localized drinks: \(error.localizedDescription)")
            loadFallbackDrinks()
        }
    }
    
    private func loadFallbackDrinks() {
        let fallbackFileName = "Drinks_en"
        guard let url = Bundle.main.url(forResource: fallbackFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let fallbackDrinks = try? JSONDecoder().decode([Drinks].self, from: data) else {
            print("Fallback drinks file not found.")
            return
        }
        DispatchQueue.main.async {
            self.drinks = fallbackDrinks
            self.updateHydratioAndLocalizedNamenMap()
        }
    }

    /// Updates the hydration map to allow fast lookup by key.
    private func updateHydratioAndLocalizedNamenMap() {
        localizedNameMap  = Dictionary(uniqueKeysWithValues: drinks.map { ($0.key, $0.name) })
        hydrationMap = Dictionary(uniqueKeysWithValues: drinks.map { ($0.key, $0.hydration) })
    }
    
    /// Returns the localized name value for a given drink key.
    func localizedName(forKey key: String) -> String? {
        return localizedNameMap[key]
    }
    
    /// Returns the hydration value for a given drink key.
    func hydration(forKey key: String) -> Double? {
        return hydrationMap[key]
    }
}

struct Drinks: Codable, Identifiable {
    let id = UUID()
    let key: String
    let name: String
    let hydration: Double

    enum CodingKeys: String, CodingKey {
        case key
        case name
        case hydration = "hydration"
    }
}
