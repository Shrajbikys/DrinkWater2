//
//  NotificationsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI
import SwiftData
import UserNotifications
import AppMetricaCore

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @Query var reminder: [Reminder]
    
    private let userDefaultsManager = UserDefaultsManager.shared
    @State private var remindersViewModel = RemindersViewModel()
    
    @State private var networkMonitor = NetworkMonitor()
    
    @State private var isAuthorizationSystemNotifications = false
    @Binding var isRemindersEnabled: Bool
    @State private var isIntervalShowingModal = false
    @State private var isSoundShowingModal = false
    @State private var pending: [String] = []
    @State private var delivered: [String] = []
    
    @State private var selectedStartTime = Date()
    @State private var selectedFinishTime = Date()
    @State private var selectedNextTime = Date()
    @State private var intervalReminder: TimeInterval = 7200
    @State private var selectedInterval: String = "2 часа"
    @State private var localizedNameInterval: [String: LocalizedStringKey] = Constants.Back.Reminder.localizedNameInterval
    @State private var selectedSound: String = "Звук 2"
    @State private var soundName: String = "Default"
    @State private var localizedNameSound = Constants.Back.Reminder.localizedNameSound
    
    @State private var isPurchaseViewModal = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Toggle(isOn: $isAuthorizationSystemNotifications) {
                            Text("Уведомления")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                        }
                        .onChange(of: isAuthorizationSystemNotifications) { _, newValue in
                            userDefaultsManager.isAuthorizationSystemNotifications = newValue
                            isAuthorizationSystemNotifications = userDefaultsManager.isAuthorizationSystemNotifications
                            if isAuthorizationSystemNotifications {
                                getPermissionSystemNotifications()
                            }
                        }
                    }
                } header: {
                    Text("Системные настройки")
                        .textCase(.uppercase)
                } footer: {
                    Text("Разрешите уведомления в настройках, чтобы мы могли отправлять вам напоминания")
                        .font(Constants.Design.Fonts.BodyMiniFont)
                        .foregroundStyle(.secondary)
                }
                Section {
                    HStack {
                        Toggle(isOn: $isRemindersEnabled) {
                            Text("Включить напоминания")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                        }
                        .onChange(of: isRemindersEnabled) { _, newValue in
                            DispatchQueue.main.async {
                                if newValue {
                                    self.removeAndAddNotification()
                                } else {
                                    self.removeOldNotifications()
                                }
                                self.remindersViewModel.updateReminders(reminder: reminder, remindersEnabled: isRemindersEnabled)
                            }
                        }
                    }
                } header: {
                    Text("Настройка приложения")
                        .textCase(.uppercase)
                }
                Section {
                    HStack{
                        Text("Начинаем")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        DatePicker("", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                            .onChange(of: selectedStartTime) { _, newDate in
                                updateStartTimeDate(newDate)
                            }
                    }
                    HStack{
                        Text("Заканчиваем")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        DatePicker("", selection: $selectedFinishTime, displayedComponents: .hourAndMinute)
                            .onChange(of: selectedFinishTime) { _, newDate in
                                updateFinishTimeDate(newDate)
                            }
                    }
                    HStack{
                        Text("Интервал")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        Button(action: {
                            isIntervalShowingModal = true
                        }) {
                            Text(localizedNameInterval[selectedInterval]!)
                                .font(Constants.Design.Fonts.BodyMediumFont)
                                .bold()
                                .foregroundStyle(.link)
                        }
                        .sheet(isPresented: $isIntervalShowingModal) {
                            IntervalModalView(reminder: reminder, isIntervalShowingModal: $isIntervalShowingModal, selectedInterval: $selectedInterval)
                                .presentationDetents([.height(250)])
                        }
                        .onChange(of: selectedInterval) { _, newValue in
                            remindersViewModel.updateReminders(reminder: reminder, intervalReminder: calcStringToTimeInterval(value: newValue))
                            removeAndAddNotification()
                        }
                    }
                } header: {
                    Text("Интервал напоминаний")
                        .textCase(.uppercase)
                }
                Section {
                    HStack {
                        Text("Звук уведомления")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        if !purchaseManager.hasPremium {
                            Text("Премиум-доступ")
                                .font(Constants.Design.Fonts.BodyMiniFont)
                            Image(systemName: "lock")
                        } else {
                            Button(action: {
                                if purchaseManager.hasPremium {
                                    isSoundShowingModal = true
                                } else {
                                    isPurchaseViewModal = true
                                }
                            }) {
                                Text(localizedNameSound[selectedSound]!)
                                    .font(Constants.Design.Fonts.BodyMediumFont)
                                    .bold()
                                    .foregroundStyle(.link)
                            }
                            .sheet(isPresented: $isSoundShowingModal) {
                                SoundModalView(reminder: reminder, isSoundShowingModal: $isSoundShowingModal, selectedSound: $selectedSound)
                                    .presentationDetents([.height(250)])
                            }
                            .onChange(of: selectedSound) { _, _ in
                                removeAndAddNotification()
                            }
                        }
                    }
                } header: {
                    Text("Оповещение")
                        .textCase(.uppercase)
                }
            }
            .listStyle(.plain)
            .onAppear {
                if networkMonitor.isConnected {
                    AppMetrica.reportEvent(name: "OpenView", parameters: ["RemindersView": ""])
                }
                
                getDataFromReminder()
            }
            .sheet(isPresented: $isPurchaseViewModal) {
                PurchaseViewWrapper(isPresented: $isPurchaseViewModal)
            }
        }
    }
}

extension RemindersView {
    
    private func getPermissionSystemNotifications() {
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus != .authorized {
                notificationsCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        updateAuthorizationSystemNotifications(true)
                        print("Request Authorization Notifications Success!")
                    } else if let error {
                        updateAuthorizationSystemNotifications(false)
                        print("Request Authorization Notifications Failed (\(error), \(error.localizedDescription))")
                    }
                }
            } else if settings.authorizationStatus == .denied {
                goToSettings()
            }
        })
    }
    
    private func updateAuthorizationSystemNotifications(_ value: Bool) {
        userDefaultsManager.isAuthorizationSystemNotifications = value
    }
    
    private func goToSettings(){
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:],
                                      completionHandler: nil)
        }
    }
    
    private func getDataFromReminder() {
        isAuthorizationSystemNotifications = userDefaultsManager.isAuthorizationSystemNotifications
        isRemindersEnabled = reminder[0].reminderEnabled
        selectedStartTime = reminder[0].startTimeReminder
        selectedFinishTime = reminder[0].finishTimeReminder
        soundName = reminder[0].soundReminder
        
        intervalReminder = reminder[0].intervalReminder
        selectedInterval = calcTimeIntervalToString(value: intervalReminder)
        
        let soundTextArray: [String: String] = ["Sound off": "Без звука", "Default": "По умолчанию", "Sound-1.aiff": "Звук 1", "Sound-2.aiff": "Звук 2", "Sound-3.aiff": "Звук 3", "Sound-4.aiff": "Звук 4", "Sound-5.aiff": "Звук 5", "Sound-6.aiff": "Звук 6"]
        selectedSound = soundTextArray[soundName] ?? "По умолчанию"
    }
    
    private func updateStartTimeDate(_ date: Date) {
        let finishTime = selectedFinishTime
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        var components = calendar.dateComponents([.hour, .minute], from: date)
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        
        if date > finishTime {
            selectedStartTime = calendar.date(from: components) ?? date
            
            DispatchQueue.main.async {
                self.remindersViewModel.updateReminders(reminder: reminder, startTimeReminder: selectedStartTime)
                self.remindersViewModel.updateReminders(reminder: reminder, finishTimeReminder: selectedStartTime)
                self.removeAndAddNotification()
            }
        } else {
            DispatchQueue.main.async {
                self.remindersViewModel.updateReminders(reminder: reminder, startTimeReminder: selectedStartTime)
                print("Update Start date \(calendar.date(from: components) ?? date)")
                self.removeAndAddNotification()
            }
        }
    }
    
    private func updateFinishTimeDate(_ date: Date) {
        let startTime = selectedStartTime
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        var components = calendar.dateComponents([.hour, .minute], from: date)
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        
        if date < startTime {
            selectedFinishTime = calendar.date(from: components) ?? date
            
            DispatchQueue.main.async {
                self.remindersViewModel.updateReminders(reminder: reminder, startTimeReminder: selectedFinishTime)
                self.remindersViewModel.updateReminders(reminder: reminder, finishTimeReminder: selectedFinishTime)
                self.removeAndAddNotification()
            }
        } else {
            DispatchQueue.main.async {
                self.remindersViewModel.updateReminders(reminder: reminder, finishTimeReminder: selectedFinishTime)
                print("Update Finish date \(calendar.date(from: components) ?? date)")
                self.removeAndAddNotification()
            }
        }
    }
    
    private func calcTimeIntervalToString(value: TimeInterval) -> String {
        let intervalArray = ["30 минут", "1 час", "1 час 30 минут", "2 часа", "2 часа 30 минут", "3 часа"]
        
        switch value {
        case 1800:
            return intervalArray[0]
        case 3600:
            return intervalArray[1]
        case 5400:
            return intervalArray[2]
        case 7200:
            return intervalArray[3]
        case 9000:
            return intervalArray[4]
        case 10800:
            return intervalArray[5]
        default:
            return intervalArray[0]
        }
    }
    
    private func calcStringToTimeInterval(value: String) -> TimeInterval {
        let intervalArray: [TimeInterval] = [1800, 3600, 5400, 7200, 9000, 10800]
        
        switch value {
        case "30 минут":
            return intervalArray[0]
        case "1 час":
            return intervalArray[1]
        case "1 час 30 минут":
            return intervalArray[2]
        case "2 часа":
            return intervalArray[3]
        case "2 часа 30 минут":
            return intervalArray[4]
        case "3 часа":
            return intervalArray[5]
        default:
            return intervalArray[0]
        }
    }
    
    func disableRemindersForToday(startDay: Date, endDay: Date, interval: TimeInterval) {
        if isRemindersEnabled {
            removeOldNotifications()
            scheduleNotificationsForDateRange(startDay: startDay, endDay: endDay, interval: interval)
        }
    }
    
    private func removeAndAddNotification() {
        if isRemindersEnabled {
            removeOldNotifications()
            scheduleNotificationsForDateRange(startDay: selectedStartTime, endDay: selectedFinishTime, interval: calcStringToTimeInterval(value: selectedInterval))
        }
    }
    
    private func scheduleDailyNotifications(startDate: Date, endDate: Date, interval: TimeInterval) {
        var soundNotifications: UNNotificationSound? = .default
        if soundName == "Sound off" {
            soundNotifications = .none
        } else {
            soundNotifications = soundName == "Default" ? .default : UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        }
        
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = String(localized: Constants.Back.Reminder.titleNotificationText)
            content.body = String(localized: Constants.Back.Reminder.bodyNotificationText.randomElement()!)
            content.sound = soundNotifications
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
                } else {
                    print(trigger)
                }
            }
            
            currentDate = currentDate.addingTimeInterval(interval)
        }
    }
    
    private func scheduleNotificationsForDateRange(startDay: Date, endDay: Date, interval: TimeInterval) {
        var currentDay = startDay
        let calendar = Calendar.current
        
        let finishDate = Calendar.current.date(byAdding: .day, value: 30, to: startDay)!
        let startDailyHourMinute = Calendar.current.dateComponents([. hour, .minute], from: startDay)
        let endDailyHourMinute = Calendar.current.dateComponents([. hour, .minute], from: endDay)
        
        while currentDay <= finishDate {
            let startDate = calendar.date(bySettingHour: startDailyHourMinute.hour!,
                                          minute: startDailyHourMinute.minute!,
                                          second: 0,
                                          of: currentDay)!
            let endDate = calendar.date(bySettingHour: endDailyHourMinute.hour!,
                                        minute: endDailyHourMinute.minute!,
                                        second: 0,
                                        of: currentDay)!
            
            scheduleDailyNotifications(startDate: startDate, endDate: endDate, interval: interval)
            
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }
    }
    
    private func removePendingNotifications(identifiers: [String]) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            self.refreshNotifications()
        }
    }
    
    private func removeDeliveredNotifications(identifiers: [String]) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
            self.refreshNotifications()
        }
    }
    
    private func refreshNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pending = requests.map({$0.identifier})
            }
        }
        UNUserNotificationCenter.current().getDeliveredNotifications { delivered in
            DispatchQueue.main.async {
                self.delivered = delivered.map({$0.request.identifier})
            }
        }
    }
    
    private func removeOldNotifications() {
        refreshNotifications()
        removePendingNotifications(identifiers: pending)
        removeDeliveredNotifications(identifiers: delivered)
    }
}

#Preview {
    RemindersView(isRemindersEnabled: .constant(true))
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}
