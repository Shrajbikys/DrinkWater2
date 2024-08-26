//
//  ComplicationsEntry.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 30.07.2024.
//

import WidgetKit

struct ComplicationsEntry: TimelineEntry {
    let date: Date
    let normDrink: Int
    let amountDrinkTotal: Int
    let percentDrinking: Int
}
