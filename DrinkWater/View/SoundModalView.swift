//
//  SoundModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.06.2024.
//

import SwiftUI
import AVFoundation

struct SoundModalView: View {
    @State var reminder: [Reminder]
    @Binding var isSoundShowingModal: Bool
    @Binding var selectedSound: String
    var player: AVAudioPlayer?
    private let nameSound = Constants.Back.Reminder.nameSound
    private let soundPlayArray = Constants.Back.Reminder.soundPlayArray
    private let soundNameArray = Constants.Back.Reminder.soundNameArray
    private let localizedNameSound = Constants.Back.Reminder.localizedNameSound
    
    @State private var remindersViewModel = RemindersViewModel()
    
    var body: some View {
        VStack {
            Text("Выберите звук уведомления:")
                .font(Constants.Design.Fonts.BodyMainFont)
                .padding(.top, 30)
            Picker("Выберите вашу норму:", selection: $selectedSound) {
                ForEach(nameSound, id: \.self) { name in
                    Text(localizedNameSound[name]!)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: selectedSound) { _, newValue in
                playSound(soundName: soundPlayArray[newValue] ?? "Default")
            }
            Button("Готово") {
                remindersViewModel.updateReminders(reminder: reminder, soundReminder: soundNameArray[selectedSound] ?? "Default")
                isSoundShowingModal = false
            }
            .font(Constants.Design.Fonts.BodyMainFont)
            .bold()
        }
    }
    
    private func playSound(soundName: String) {
        if soundName != "Default" {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "aiff") else { return }

            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        } else {
            AudioServicesPlaySystemSound(1012)
        }
    }
}

#Preview {
    let reminder = [Reminder(remindersEnabled: true, startTimeReminder: Date(), finishTimeReminder: Date(), nextTimeReminder: Date(), intervalReminder: 1800, soundReminder: "Default")]
    return SoundModalView(reminder: reminder, isSoundShowingModal: .constant(false), selectedSound: .constant("Default"))
}
