//
//  HydrationView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI
import AppMetricaCore

struct HydrationView: View {
    @EnvironmentObject var drinkProvider: DrinkDataProvider
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(drinkProvider.drinks.sorted(by: {$0.name < $1.name})) { drink in
                    HydrationItemView(nameDrink: drink.name, imageDrink: drink.key , hydration: drink.hydration)
                }
            }
        }
        .navigationTitle("Коэффициенты гидратации")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HydrationView()
        .environmentObject(DrinkDataProvider())
}
