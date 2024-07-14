//
//  DataDrinkingOfTheDay.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import SwiftData

@Model
final class DataDrinkingOfTheDay: Identifiable {
    var id: String = "F092DD2A-6CD3-4CD4-901F-5FED9CBA6896"
    var dayID: String = "20240101"
    var amountDrinkOfTheDay: Int = 100
    var dateDrinkOfTheDay: Date = Date()
    var percentDrinking: Double = 10.0
    
    init(amountDrinkOfTheDay: Int, dateDrinkOfTheDay: Date, percentDrinking: Double) {
        self.id = UUID().uuidString
        self.dayID = dateDrinkOfTheDay.yearMonthDay
        self.amountDrinkOfTheDay = amountDrinkOfTheDay
        self.dateDrinkOfTheDay = dateDrinkOfTheDay
        self.percentDrinking = percentDrinking
    }
}
