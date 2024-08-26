//
//  DrinkDataViewModel.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import Observation
import SwiftData

@Observable
class DataDrinkingViewModel {
    
    func updateDataDrinking(modelContext: ModelContext, nameDrink: String, amountDrink: Int, dateDrink: Date) {
        let dataDrinking = DataDrinking(nameDrink: nameDrink, amountDrink: amountDrink, dateDrink: dateDrink)
        modelContext.insert(dataDrinking)
    }
    
    func deleteItemDataDrinking(modelContext: ModelContext, itemDataDrinking: DataDrinking) {
        modelContext.delete(itemDataDrinking)
    }
    
    func deleteAllDataDataDrinking(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: DataDrinking.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Функция проверки наличия записей за текущий день
    func isAvailiableRecordOfTheCurrentDay(dataDrinking: [DataDrinking]) -> Bool {
        guard !dataDrinking.isEmpty && dataDrinking.last?.dateDrink.yearMonthDay == Date().yearMonthDay else {
            return false
        }
        return true
    }
}
