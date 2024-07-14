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
    
    private let nameInterval = ["30 минут", "1 час", "1 час 30 минут", "2 часа", "2 часа 30 минут", "3 часа"]
    
    var body: some View {
        VStack {
            Text("Выберите интервал:")
                .font(.headline)
                .padding(.top, 30)
            Picker("Выберите интервал:", selection: $selectedInterval) {
                ForEach(nameInterval, id: \.self) { name in
                    Text(name)
                }
            }
            .pickerStyle(.wheel)
            Button("Готово") {
                remindersViewModel.updateReminders(reminder: reminder, intervalReminder: calcStringToTimeInterval(value: selectedInterval))
                isIntervalShowingModal = false
            }
            .bold()
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
}

//#Preview {
//    IntervalModalView()
//}
