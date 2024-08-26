//
//  WidgetContent.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import WidgetKit

struct WidgetEntry: TimelineEntry {
    let date: Date
    let normDrink: Int
    let amountDrink: Int
    let percentDrinking: Int
    let nameDrink: String
    let unit: Int
}
