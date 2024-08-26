//
//  CircularComplicationView.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 28.07.2024.
//

import SwiftUI
import WidgetKit

struct CircularComplication: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var entry: ComplicationsEntry
    
    var body: some View {
        Gauge(value: Double(entry.amountDrinkTotal), in: 0...Double(entry.normDrink)) {
            Text("мл")
        } currentValueLabel: {
            if renderingMode == .fullColor {
                Text("\(entry.amountDrinkTotal)")
                    .foregroundColor(.orange)
            }
            else {
                Text("\(entry.amountDrinkTotal)")
            }
        }
        .containerBackground(.background, for: .widget)
        .gaugeStyle(.circular)
        .tint(.cyan)
    }
}

#Preview(as: .accessoryCircular) {
    DrinkWaterComplications()
} timeline: {
    ComplicationsEntry(date: Date(), normDrink: 2100, amountDrinkTotal: 700, percentDrinking: 35)
}
