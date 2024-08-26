//
//  PreviewContainer.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 09.08.2024.
//

import Foundation
import SwiftData

@MainActor
class PreviewContainer {
    static let previewContainer: ModelContainer = {
        do {
            let schema = Schema([Profile.self, DataDrinking.self, DataDrinkingOfTheDay.self, Reminder.self])
            let container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            
            SampleData.profile.enumerated().forEach { _, profile in
                container.mainContext.insert(profile)
            }
            SampleData.dataDrinking.enumerated().forEach { _, dataDrinkingItem in
                container.mainContext.insert(dataDrinkingItem)
            }
            SampleData.dataDrinkingOfTheDay.enumerated().forEach { _, dataDrinkingOfTheDayItem in
                container.mainContext.insert(dataDrinkingOfTheDayItem)
            }
            SampleData.reminder.enumerated().forEach { _, reminderItem in
                container.mainContext.insert(reminderItem)
            }
            
            return container
            
        } catch {
            fatalError("Failed to create container.")
        }
    }()
}

struct SampleData {
    static let profile: [Profile] = {
        return [Profile(gender: .man, weightKg: 55, unit: 0, autoNormMl: 1900, customNormMl: 1900, weightPounds: 121, autoNormOz: 67, customNormOz: 67, autoCalc: true, lastAmountDrink: 250, lastNameDrink: "Water")]
    }()
    
    static let dataDrinking: [DataDrinking] = {
        return (1...5).map { _ in DataDrinking(nameDrink: "Water", amountDrink: 250, dateDrink: Date()) }
    }()
    
    static let dataDrinkingOfTheDay: [DataDrinkingOfTheDay] = {
        return (1...5).map { value in DataDrinkingOfTheDay(amountDrinkOfTheDay: 200 * value, dateDrinkOfTheDay: Date(), percentDrinking: 10 * Double(value)) }
    }()
    
    static let reminder: [Reminder] = {
        return [Reminder(remindersEnabled: true, startTimeReminder: Date(), finishTimeReminder: Date(), nextTimeReminder: Date(), intervalReminder: 1800, soundReminder: "Default")]
    }()
}
