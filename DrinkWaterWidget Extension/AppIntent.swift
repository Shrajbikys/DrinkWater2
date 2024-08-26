//
//  AppIntent.swift
//  DrinkWaterWidget
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    
    static var date = Date()
    static var normDrink: Int = 2000
    static var amountDrink: Int = 1000
    static var percentDrinking: Int = 70
    static var nameDrink: String = "Water"
    static var unit: Int = 0
}
