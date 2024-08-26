//
//  WidgetManager.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 22.07.2024.
//

import WidgetKit

class WidgetManager {
    private static let userDefaultsManager = UserDefaultsManager.shared
    
    /// Функция отправки данных в Widget
    static func sendDataToWidget(_ norm: Double, _ amountDrinkingOfTheDay: Int, _ percentDrinkNew: CGFloat, _ lastNameDrink: String, _ unitValue: Int, _ isPremium: Bool) {
        
        let dateLastDrink = Date().dateFormatForWidgetAndWatch
        
        userDefaultsManager.setValueForUserDefaults(norm, "normDrink")
        userDefaultsManager.setValueForUserDefaults(amountDrinkingOfTheDay, "amountDrinkTotal")
        userDefaultsManager.setValueForUserDefaults(percentDrinkNew, "percentDrink")
        userDefaultsManager.setValueForUserDefaults(lastNameDrink, "nameDrink")
        userDefaultsManager.setValueForUserDefaults(unitValue, "unit")
        userDefaultsManager.setValueForUserDefaults(dateLastDrink, "dateLastDrink")
        userDefaultsManager.setValueForUserDefaults(isPremium, "com.alexander.l.DrinkWater.subscription.forever")
    }
}
