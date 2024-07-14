//
//  DrinkDataOfDayViewModel.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import Observation
import SwiftData

@Observable
class DataDrinkingOfTheDayViewModel {
    
    func updateDataDrinkingOfTheDay(modelContext: ModelContext, dataDrinkingOfTheDay: [DataDrinkingOfTheDay], amountDrinkOfTheDay: Int, dateDrinkOfTheDay: Date, percentDrinking: Double) {
        if dataDrinkingOfTheDay.isEmpty || dataDrinkingOfTheDay.last?.dateDrinkOfTheDay.yearMonthDay != Date().yearMonthDay {
            let dataDrinkingOfTheDay = DataDrinkingOfTheDay(amountDrinkOfTheDay: amountDrinkOfTheDay, dateDrinkOfTheDay: dateDrinkOfTheDay, percentDrinking: percentDrinking)
            modelContext.insert(dataDrinkingOfTheDay)
        } else {
            dataDrinkingOfTheDay.last?.amountDrinkOfTheDay += amountDrinkOfTheDay
            dataDrinkingOfTheDay.last?.percentDrinking += percentDrinking
        }
    }
    
    func updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: [DataDrinkingOfTheDay], percentDrinking: Double) {
        if dataDrinkingOfTheDay.last?.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay && dataDrinkingOfTheDay.last?.amountDrinkOfTheDay ?? 0 > 0 {
            dataDrinkingOfTheDay.last?.percentDrinking = percentDrinking
        }
    }
    
    func cancelDataDrinkingOfTheDay(modelContext: ModelContext, dataDrinkingOfTheDay: [DataDrinkingOfTheDay], amountDrinkOfTheDay: Int, percentDrinking: Double) {
        dataDrinkingOfTheDay.last?.amountDrinkOfTheDay -= amountDrinkOfTheDay
        dataDrinkingOfTheDay.last?.percentDrinking -= percentDrinking
    }
    
    func deleteAllDataDataDrinkingOfTheDay(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: DataDrinkingOfTheDay.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Функция получения последней записи за текущий день
    func getLastRecordOfTheCurrentDay(dataDrinkingOfTheDay: [DataDrinkingOfTheDay]) -> DataDrinkingOfTheDay? {
        guard !dataDrinkingOfTheDay.isEmpty && dataDrinkingOfTheDay.last?.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay else {
            return nil
        }
        print(dataDrinkingOfTheDay.count)
        return dataDrinkingOfTheDay.last
    }

    /// Функция получения последней записи за текущий день
    func isAvailiableRecordOfTheCurrentDay(dataDrinkingOfTheDay: [DataDrinkingOfTheDay]) -> Bool {
        guard !dataDrinkingOfTheDay.isEmpty && dataDrinkingOfTheDay.last?.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay else {
            return false
        }
        
        return true
    }

}
