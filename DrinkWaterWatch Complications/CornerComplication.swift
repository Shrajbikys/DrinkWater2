//
//  CornerComplicationView.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 28.07.2024.
//

import SwiftUI
import WidgetKit

struct CornerComplication: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var entry: ComplicationsEntry
    
    var body: some View {
        ZStack {
            if renderingMode == .fullColor {
                Image("ButtonComplication")
                    .font(.title.bold())
            } else {
                Text("💧")
                    .font(.system(size: 30))
            }
        }
        .widgetLabel {
            Text("\(Text("\(entry.amountDrinkTotal)").foregroundStyle(.green))•\(Text("\(entry.normDrink)").foregroundStyle(.cyan))•\(Text("\(entry.percentDrinking)%").foregroundStyle(.orange))")
        }
        .containerBackground(.background, for: .widget)
    }
}

#Preview(as: .accessoryCorner) {
    DrinkWaterComplications()
} timeline: {
    ComplicationsEntry(date: Date(), normDrink: 2100, amountDrinkTotal: 700, percentDrinking: 35)
}
