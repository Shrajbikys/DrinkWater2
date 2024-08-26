//
//  Date+toString.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation

extension Date {

    var abbreviatedMonth: String {
        DateFormatter.abbreviatedMonth.string(from: self)
    }

    var dayOfWeekWithMonthAndDay: String {
        DateFormatter.dayOfWeekWithMonthAndDay.string(from: self)
    }
    
    var dayOfWeekWithMonthAndDayRu: String {
        DateFormatter.dayOfWeekWithMonthAndDayRu.string(from: self)
    }

    var fullMonth: String {
        DateFormatter.fullMonth.string(from: self)
    }
    
    var fullMonthRu: String {
        DateFormatter.fullMonthRu.string(from: self)
    }

    var timeOnlyWithPadding: String {
        DateFormatter.timeOnlyWithPadding.string(from: self)
    }

    var year: String {
        DateFormatter.year.string(from: self)
    }
    
    var yearMonthDay: String {
        DateFormatter.formatterYearMonthDay.string(from: self)
    }

}

extension DateFormatter {

    static var abbreviatedMonth: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    static var dayOfWeekWithMonthAndDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d"
        return formatter
    }
    
    static var dayOfWeekWithMonthAndDayRu: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter
    }
    
    static var monthOfYearWithMonthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d"
        return formatter
    }

    static var fullMonth: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }
    
    static var fullMonthRu: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL"
        return formatter
    }

    static let timeOnlyWithPadding: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static var year: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static let formatterMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.yyyy"
        return formatter
    }()
    
    static let formatterYearMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}
