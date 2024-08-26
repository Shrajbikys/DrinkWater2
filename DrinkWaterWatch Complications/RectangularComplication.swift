//
//  RectangularComplicationView.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 28.07.2024.
//

import SwiftUI
import WidgetKit

struct RectangularComplication: View {
    var entry: ComplicationsEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Цель:")
                    .foregroundStyle(.white)
                Text("\(entry.normDrink) мл")
                    .foregroundStyle(.green)
            }
            HStack {
                Text("Выпито:")
                    .foregroundStyle(.white)
                Text("\(entry.amountDrinkTotal) мл")
                    .foregroundStyle(.orange)
            }
            HStack {
                Text("Завершено:")
                    .foregroundStyle(.white)
                Text("\(entry.percentDrinking) %")
                    .foregroundStyle(.cyan)
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

#Preview(as: .accessoryRectangular) {
    DrinkWaterComplications()
} timeline: {
    ComplicationsEntry(date: Date(), normDrink: 2100, amountDrinkTotal: 700, percentDrinking: 35)
}
