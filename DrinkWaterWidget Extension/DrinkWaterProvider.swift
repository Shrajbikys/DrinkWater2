//
//  DrinkWaterProvider.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 27.07.2024.
//

import Foundation
import SwiftUI
import WidgetKit

struct DrinkWaterProvider: AppIntentTimelineProvider {
    @AppStorage("dateLastDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var dateLastDrink: String = ""
    @AppStorage("nameDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var nameDrink: String = "Water"
    @AppStorage("normDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var normDrink: Int = 2000
    @AppStorage("amountDrinkTotal", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var amountDrinkTotal: Int = 0
    @AppStorage("percentDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var percentDrink: Int = 0
    @AppStorage("unit", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var unit: Int = 0
    
    let snapshotEntry = WidgetEntry(date: Date(), normDrink: 0, amountDrink: 0, percentDrinking: 0, nameDrink: "Water", unit: 0)
    
    func placeholder(in context: Context) -> WidgetEntry {
        snapshotEntry
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetEntry {
        snapshotEntry
    }
    
    func readContents() -> WidgetEntry {
        let dateNow: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateNow = dateFormatter.string(from: Date())
        
        var contents: WidgetEntry?
        if dateNow == dateLastDrink {
            contents = WidgetEntry(date: Date(), normDrink: normDrink, amountDrink: amountDrinkTotal, percentDrinking: percentDrink, nameDrink: nameDrink, unit: unit)
        } else {
            contents = snapshotEntry
        }
        return contents ?? snapshotEntry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetEntry> {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let entries: [WidgetEntry] = [readContents()]
        return Timeline(entries: entries, policy: .after(nextMidnight))
    }
}
