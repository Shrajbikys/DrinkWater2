//
//  Notifications.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import SwiftData

@Model
final class Reminder {
    var reminderEnabled: Bool = false
    var startTimeReminder: Date = Date()
    var finishTimeReminder: Date = Date()
    var nextTimeReminder: Date = Date()
    var intervalReminder: TimeInterval = 5400
    var soundReminder: String = "Default"
    
    init(remindersEnabled: Bool, startTimeReminder: Date, finishTimeReminder: Date, nextTimeReminder: Date, intervalReminder: TimeInterval, soundReminder: String) {
        self.reminderEnabled = remindersEnabled
        self.startTimeReminder = startTimeReminder
        self.finishTimeReminder = finishTimeReminder
        self.nextTimeReminder = nextTimeReminder
        self.intervalReminder = intervalReminder
        self.soundReminder = soundReminder
    }
}
