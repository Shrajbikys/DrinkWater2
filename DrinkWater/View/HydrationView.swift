//
//  HydrationView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI

struct HydrationView: View {
    let hydration: [String: Double] = ["Water": 1.0, "Coffee": 0.8, "Tea": 0.9, "Milk": 0.9, "Juice": 0.8, "Soda": 0.9, "Cocoa": 0.7, "Smoothie": 0.3, "Yogurt": 0.5, "Beer": -0.6, "NonalcoholicBeer": 0.6, "Wine": -1.6]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(hydration.sorted(by: <), id: \.key) { key, value in
                    HydrationItemView(nameDrink: key, imageDrink: "\(key)CA" , hydration: value)
                }
            }
        }
        .navigationTitle("Коэффициенты гидратации")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HydrationView()
}
