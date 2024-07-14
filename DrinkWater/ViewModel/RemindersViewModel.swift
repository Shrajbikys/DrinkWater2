//
//  NotificationsViewModel.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import SwiftData

class RemindersViewModel {
    
    func firstLoadReminders(modelContext: ModelContext) {
        let firtsReminder = Reminder(remindersEnabled: false, startTimeReminder: Date(), finishTimeReminder: Date(), nextTimeReminder: Date(), intervalReminder: 5400, soundReminder: "Default")
        modelContext.insert(firtsReminder)
    }
    
    func updateReminders(reminder: [Reminder], remindersEnabled: Bool) {
        reminder[0].reminderEnabled = remindersEnabled
    }
    
    func updateReminders(reminder: [Reminder], startTimeReminder: Date) {
        reminder[0].startTimeReminder = startTimeReminder
    }
    
    func updateReminders(reminder: [Reminder], finishTimeReminder: Date) {
        reminder[0].finishTimeReminder = finishTimeReminder
    }
    
    func updateReminders(reminder: [Reminder], nextTimeReminder: Date) {
        reminder[0].nextTimeReminder = nextTimeReminder
    }
    
    func updateReminders(reminder: [Reminder], intervalReminder: TimeInterval) {
        reminder[0].intervalReminder = intervalReminder
    }
    
    func updateReminders(reminder: [Reminder], soundReminder: String) {
        reminder[0].soundReminder = soundReminder
    }
}
