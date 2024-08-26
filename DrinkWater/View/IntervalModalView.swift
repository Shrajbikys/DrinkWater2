//
//  IntervalModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.06.2024.
//

import SwiftUI

struct IntervalModalView: View {
    @State var reminder: [Reminder]
    @Binding var isIntervalShowingModal: Bool
    @Binding var selectedInterval: String
    
    @State private var remindersViewModel = RemindersViewModel()
    
    private let nameInterval: [String] = Constants.Back.Reminder.nameInterval
    private let nameToTimeInterval: [String: TimeInterval] = Constants.Back.Reminder.nameToTimeInterval
    private let localizedNameInterval: [String: LocalizedStringKey] = Constants.Back.Reminder.localizedNameInterval
    
    var body: some View {
        VStack {
            Text("Выберите интервал:")
                .font(Constants.Design.Fonts.BodyMainFont)
                .padding(.top, 30)
            Picker("Выберите интервал:", selection: $selectedInterval) {
                ForEach(nameInterval, id: \.self) { name in
                    Text(localizedNameInterval[name]!)
                }
            }
            .pickerStyle(.wheel)
            Button("Готово") {
                remindersViewModel.updateReminders(reminder: reminder, intervalReminder: nameToTimeInterval[selectedInterval]!)
                isIntervalShowingModal = false
            }
            .font(Constants.Design.Fonts.BodyMainFont)
            .bold()
        }
    }
}

#Preview {
    let reminder = [Reminder(remindersEnabled: true, startTimeReminder: Date(), finishTimeReminder: Date(), nextTimeReminder: Date(), intervalReminder: 1800, soundReminder: "Default")]
    return IntervalModalView(reminder: reminder, isIntervalShowingModal: .constant(false), selectedInterval: .constant("1 час 30 минут"))
}
