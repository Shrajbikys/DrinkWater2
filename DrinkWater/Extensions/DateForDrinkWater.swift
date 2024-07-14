//
//  DateForDrinkWater.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation

extension Date {
    /// Получаем начало дня
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Получаем конец дня
    var endOfDay: Date {
        let calendar = Calendar.current
        let endDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: startOfDay))
        return endDay!
    }

    /// Получаем дату начала недели
    var thisWeekStart: Date {
        let calendar = Calendar.current
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return sunday!
    }

    /// Получаем дату конца недели
    var thisWeekEnd: Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: thisWeekStart)!
    }

    /// Получаем дату начала месяца
    var thisMonthStart: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }

    /// Получаем дату конца месяца
    var thisMonthEnd: Date {
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: thisMonthStart)
        return endOfMonth!
    }

    /// Форматирование даты последнего входа под текущий часовой пояс
    var lastSignInDateFormatter: Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let day = dateFormatter.date(from: "\(dateComponents.year!)/\(dateComponents.month!)/\(dateComponents.day!)")

        return day!
    }

    /// Получаем даты текущей недели
    var thisWeek: [Date] {
        var arrThisWeek: [Date] = []
        for i in 0..<7 {
            arrThisWeek.append(Calendar.current.date(byAdding: .day, value: i, to: thisWeekStart)!)
        }
        return arrThisWeek
    }

    /// Получаем даты следующей недели
    var nextWeek: [Date] {
        var arrNextWeek: [Date] = []
        for i in 1...7 {
            arrNextWeek.append(Calendar.current.date(byAdding: .day, value: i, to: thisWeek.last!)!)
        }
        return arrNextWeek
    }

    /// Получаем даты прошлой недели
    var lastWeek: [Date] {
        var arrLastWeek: [Date] = []
        for i in 1...7 {
            arrLastWeek.append(Calendar.current.date(byAdding: .day, value: -i, to: thisWeek.first!)!)
        }
        return Array(arrLastWeek.reversed())
    }

    /// Получаем начало прошлого месяца
    var lastMonthStart: Date {
        let startOfLastMonth = Calendar.current.date(byAdding: .month, value: -1, to: thisMonthStart)
        return startOfLastMonth!
    }

    /// Получаем конец прошлого месяца
    var lastMonthEnd: Date {
        let endOfLastMonth = Calendar.current.date(byAdding: .day, value: -1, to: thisMonthStart)
        return endOfLastMonth!
    }

    /// Получаем начало следующего месяца
    var nextMonthStart: Date {
        let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: thisMonthStart)
        return startOfNextMonth!
    }

    /// Получаем конец следующего месяца
    var nextMonthEnd: Date {
        let endOfNextMonth = Calendar.current.date(byAdding: DateComponents(month: 2, day: -1), to: thisMonthStart)
        return endOfNextMonth!
    }

    /// Форматирование даты, пример: "10 Июля 2020" или "10 May 2021"
    var formatForPeriodDates: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: self).capitalized
    }

    /// Получаем время в формате HH:mm - пример: "23:00" или "2:20 AM"
    var timeOfHourAndMinutes: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = amPMFormat() ? "h:mm a" : "HH:mm"
        return dateFormatter.string(from: self)
    }

    /// Получение номера дня в строковом формате
    var dayShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    /// Получение номера дня в числовом формате
    var dayOfMonth: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return Int(dateFormatter.string(from: self))!
    }

    /// Получаем название месяца в коротком формате
    var monthShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }

    /// Получаем номер дня недели текущего дня
    var dayOfWeek: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ee"
        return Int(dateFormatter.string(from: self))!
    }

    /// Получаем название дня в коротком формате
    var nameDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eee"
        return dateFormatter.string(from: self).uppercased()
    }

    /// Получаем форматированную дату для передачи в виджет и часы
    var dateFormatForWidgetAndWatch: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }

    /// Определение 12/24 формата
    func amPMFormat() -> Bool {
        let now = Date()
        if now.localizedDateDescription.contains("AM") || now.localizedDateDescription.contains("PM") {
            return true
        }
        return false
    }

    /// Получаем сегодняшнее число текущего месяца
    var numDayMonth: Int {
        let numDayMonth = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        return numDayMonth.day!
    }

    /// Функция создания массива с датами в течение которых приложение не запускалось (необходимо для отрисовки collection view на экране статистики)
    var findMissDate: [Date] {

        var fromInterval = self.timeIntervalSince1970
        let toInterval = Date().lastSignInDateFormatter.timeIntervalSince1970
        var dates = [Date]()

        while fromInterval < toInterval {
            fromInterval += 60 * 60 * 24
            dates.append(Date(timeIntervalSince1970: fromInterval))
        }
        return dates
    }
}

extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDateDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                           in timeZone: TimeZone = .current,
                              locale: Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }

    func localizedTimeDescription(timeStyle: DateFormatter.Style = .short,
                           in timeZone: TimeZone = .current,
                              locale: Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDateDescription: String { return localizedDateDescription() }
    var localizedTimeDescription: String { return localizedTimeDescription() }
}

extension String {
    /// Форматирование периода дат из Label-а
    var stringPeriodDate: Date {
        let stringDate = self.split(separator: "-").dropLast()[0].trimmingCharacters(in: .whitespaces)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.date(from: stringDate)!
    }
}
