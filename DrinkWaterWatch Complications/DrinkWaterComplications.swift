//
//  DrinkWaterWatch_Complications.swift
//  DrinkWaterWatch Complications
//
//  Created by Alexander Lyubimov on 28.07.2024.
//

import WidgetKit
import SwiftUI

@main
struct DrinkWaterComplications: Widget {
    let kind: String = "DrinkWaterWatch_ComplicationsCorner"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: ComplicationsProvider()) { entry in
            DrinkWaterComplicationsView(entry: entry)
        }
        .configurationDisplayName("Попей водички")
        .description("Описание")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

#Preview(as: .accessoryCorner) {
    DrinkWaterComplications()
} timeline: {
    ComplicationsEntry(date: Date(), normDrink: 2100, amountDrinkTotal: 700, percentDrinking: 35)
}
