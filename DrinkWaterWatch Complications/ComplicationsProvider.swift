//
//  ComplicationsProvider.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 30.07.2024.
//

import SwiftUI
import WidgetKit

struct ComplicationsProvider: AppIntentTimelineProvider {
    @AppStorage("dateLastDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch")) var dateLastDrink: String = ""
    @AppStorage("normDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch")) var normDrink: Int = 2000
    @AppStorage("amountDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch")) var amountDrinkTotal: Int = 0
    @AppStorage("percentDrink", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch")) var percentDrink: Int = 0
    
    let snapshotEntry = ComplicationsEntry(date: Date(), normDrink: 0, amountDrinkTotal: 0, percentDrinking: 0)
    
    func placeholder(in context: Context) -> ComplicationsEntry {
        snapshotEntry
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ComplicationsEntry {
        readContents()
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ComplicationsEntry> {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        
        let entries: [ComplicationsEntry] = [readContents()]
        return Timeline(entries: entries, policy: .after(nextMidnight))
    }
    
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Попей водички")]
    }
    
    func readContents() -> ComplicationsEntry {
        let dateNow: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateNow = dateFormatter.string(from: Date())
        
        var contents: ComplicationsEntry?
        if dateNow == dateLastDrink {
            contents = ComplicationsEntry(date: Date(), normDrink: normDrink, amountDrinkTotal: amountDrinkTotal, percentDrinking: percentDrink)
        } else {
            contents = snapshotEntry
        }
        
        return contents ?? snapshotEntry
    }
}
