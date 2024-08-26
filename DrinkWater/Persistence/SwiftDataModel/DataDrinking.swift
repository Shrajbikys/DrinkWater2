//
//  DataDrinking.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import SwiftData

@Model
final class DataDrinking: Identifiable {
    var id: String = UUID().uuidString
    var nameDrink: String = "Water"
    var amountDrink: Int = 100
    var dateDrink: Date = Date()
    
    init(nameDrink: String, amountDrink: Int, dateDrink: Date) {
        self.id = UUID().uuidString
        self.nameDrink = nameDrink
        self.amountDrink = amountDrink
        self.dateDrink = dateDrink
    }
}
