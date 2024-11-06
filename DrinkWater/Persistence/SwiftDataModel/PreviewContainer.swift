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
            let schema = Schema([Profile.self, DataDrinking.self, DataDrinkingOfTheDay.self, Reminder.self, DataWeight.self])
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
            SampleData.dataWeight.enumerated().forEach { _, dataWeightItem in
                container.mainContext.insert(dataWeightItem)
            }
            
            return container
            
        } catch {
            fatalError("Failed to create container.")
        }
    }()
}

struct SampleData {
    static let profile: [Profile] = {
        return [Profile(gender: .man, weightKg: 55.4, heightCm: 170, unit: 0, autoNormMl: 1900, customNormMl: 1900, weightPounds: 121.8, autoNormOz: 67, customNormOz: 67, autoCalc: true, lastAmountDrink: 250, lastNameDrink: "Water")]
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
    
    static let dataWeight: [DataWeight] = {
        return [DataWeight(date: Date(), goal: 78.1, weight: 84.1, difference: 12.2), DataWeight(date: Date() - 100000, goal: 78.1, weight: 86.3, difference: 4.2),
                DataWeight(date: Date() - 200000, goal: 78.1, weight: 89.8, difference: 4.2), DataWeight(date: Date() - 300000, goal: 78.1, weight: 94.5, difference: 4.2)]
    }()
}
