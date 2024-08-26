//
//  InlineComplicationView.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 28.07.2024.
//

import SwiftUI
import WidgetKit

struct InlineComplication: View {
    var entry: ComplicationsEntry
    
    var body: some View {
        Text("💧Выпито: \(entry.amountDrinkTotal) мл")
            .containerBackground(.background, for: .widget)
    }
}

#Preview(as: .accessoryInline) {
    DrinkWaterComplications()
} timeline: {
    ComplicationsEntry(date: Date(), normDrink: 2100, amountDrinkTotal: 700, percentDrinking: 35)
}
