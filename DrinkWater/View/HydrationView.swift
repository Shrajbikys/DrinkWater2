//
//  HydrationView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI
import AppMetricaCore

struct HydrationView: View {
    let hydration: [String: Double] = Constants.Back.Drink.hydration
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(hydration.sorted(by: <), id: \.key) { key, value in
                    HydrationItemView(nameDrink: key, imageDrink: "\(key)CA" , hydration: value)
                }
            }
            .onAppear { AppMetrica.reportEvent(name: "OpenView", parameters: ["HydrationView": ""]) }
        }
        .navigationTitle("Коэффициенты гидратации")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HydrationView()
}
