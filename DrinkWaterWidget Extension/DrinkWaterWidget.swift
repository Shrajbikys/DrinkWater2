//
//  DrinkWaterWidget.swift
//  DrinkWaterWidget
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import WidgetKit
import SwiftUI

struct DrinkWaterWidgetSmall: Widget {
    let kind: String = "DrinkWaterWidgetSmall"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: DrinkWaterProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Drink Water Widget")
        .description("Следите за своим потреблением воды")
        .supportedFamilies([.systemSmall])
    }
}

struct DrinkWaterWidgetMedium: Widget {
    let kind: String = "DrinkWaterWidgetMedium"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: DrinkWaterProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Drink Water Widget")
        .description("Следите за своим потреблением воды")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    DrinkWaterWidgetSmall()
} timeline: {
    WidgetEntry(date: .now, normDrink: 2000, amountDrink: 1000, percentDrinking: 50, nameDrink: "Water", unit: 0)
}

#Preview(as: .systemMedium) {
    DrinkWaterWidgetMedium()
} timeline: {
    WidgetEntry(date: .now, normDrink: 2000, amountDrink: 1000, percentDrinking: 50, nameDrink: "Water", unit: 0)
}
