//
//  Calender+Dates.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation

extension Calendar {
    
    var dayOfWeekInitials: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        var veryShortWeekdaySymbols2 = dateFormatter.veryShortWeekdaySymbols
        let mondayIndex = veryShortWeekdaySymbols2!.firstIndex(of: "Вс")!
        let mondaySymbol = veryShortWeekdaySymbols2!.remove(at: mondayIndex)
        veryShortWeekdaySymbols2?.insert(mondaySymbol, at: 6)
        return veryShortWeekdaySymbols2!
    }
}

extension Calendar {

    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date))!
    }

    func isDate(_ date1: Date, equalTo date2: Date, toGranularities components: Set<Calendar.Component>) -> Bool {
        components.reduce(into: true) { isEqual, component in
            isEqual = isEqual && isDate(date1, equalTo: date2, toGranularity: component)
        }
    }

    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.month, .year], from: date)
        return self.date(from: components)!
    }

    func startOfYear(for date: Date) -> Date {
        let components = dateComponents([.year], from: date)
        return self.date(from: components)!
    }

}

extension Calendar {

    func generateDates(inside interval: DateInterval,
                       matching components: DateComponents) -> [Date] {
       var dates: [Date] = []
       dates.append(interval.start)

       enumerateDates(
           startingAfter: interval.start,
           matching: components,
           matchingPolicy: .nextTime) { date, _, stop in
           if let date = date {
               if date < interval.end {
                   dates.append(date)
               } else {
                   stop = true
               }
           }
       }

       return dates
    }

}

extension Date {

    static func daysFromToday(_ days: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(60*60*24*days))
    }
    
    static func daysFromTodayNew(_ date: Date, _ days: Int) -> Date {
        date.addingTimeInterval(TimeInterval(60*60*24*days))
    }

    func monthYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: self)
        return calendar.date(from: components)!
    }
    
    func dayMonthYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: self)
        return calendar.date(from: components)!
    }
    
    func compareDate(date: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date)

        if components1.year == components2.year && components1.month == components2.month && components1.day == components2.day {
            return true
        }
        return false
    }
    
    static func compareDatesWithoutTime(date1: Date, date2: Date) -> ComparisonResult {
        // Создаем календарь
        let calendar = Calendar.current
        
        // Получаем компоненты даты (год, месяц и день) для обеих дат
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        // Создаем новые даты только с компонентами года, месяца и дня
        guard let newDate1 = calendar.date(from: components1),
              let newDate2 = calendar.date(from: components2) else {
            // Обработка ошибки, если не удается создать новые даты
            fatalError("Не удалось создать новые даты")
        }
        
        // Сравниваем две новые даты
        return newDate1.compare(newDate2)
    }
    
    static func compareDatesWithoutDayAndTime(date1: Date, date2: Date) -> ComparisonResult {
        // Создаем календарь
        let calendar = Calendar.current
        
        // Получаем компоненты даты (год, месяц и день) для обеих дат
        let components1 = calendar.dateComponents([.year, .month], from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        
        // Создаем новые даты только с компонентами года, месяца и дня
        guard let newDate1 = calendar.date(from: components1),
              let newDate2 = calendar.date(from: components2) else {
            // Обработка ошибки, если не удается создать новые даты
            fatalError("Не удалось создать новые даты")
        }
        
        // Сравниваем две новые даты
        return newDate1.compare(newDate2)
    }
}
