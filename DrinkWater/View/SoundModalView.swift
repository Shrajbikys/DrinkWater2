//
//  SoundModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.06.2024.
//

import SwiftUI

struct SoundModalView: View {
    @State var reminder: [Reminder]
    @Binding var isSoundShowingModal: Bool
    @Binding var selectedSound: String
    private let nameSound = ["Без звука", "По умолчанию", "Звук 1", "Звук 2", "Звук 3", "Звук 4", "Звук 5", "Звук 6"]
    private let soundNameArray = ["Без звука": "Sound off", "По умолчанию": "Default", "Звук 1": "Sound-1.aiff", "Звук 2": "Sound-2.aiff", "Звук 3": "Sound-3.aiff", "Звук 4": "Sound-4.aiff", "Звук 5": "Sound-5.aiff", "Звук 6": "Sound-6.aiff"]
    
    @State private var remindersViewModel = RemindersViewModel()
    
    var body: some View {
        VStack {
            Text("Выберите звук уведомления:")
                .font(.headline)
                .padding(.top, 30)
            Picker("Выберите вашу норму:", selection: $selectedSound) {
                ForEach(nameSound, id: \.self) { name in
                    Text(name)
                }
            }
            .pickerStyle(.wheel)
            Button("Готово") {
                remindersViewModel.updateReminders(reminder: reminder, soundReminder: soundNameArray[selectedSound] ?? "Default")
                isSoundShowingModal = false
            }
            .bold()
        }
    }
}

//#Preview {
//    SoundModalView()
//}
