//
//  CustomAmountView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 28.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData
import AppMetricaCore

struct CustomAmountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    @EnvironmentObject var drinkProvider: DrinkDataProvider
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    @Query var reminder: [Reminder]
    
    @State private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State var profileViewModel = ProfileViewModel()
    @State var dataDrinkingViewModel = DataDrinkingViewModel()
    @State var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    
    @State private var networkMonitor = NetworkMonitor()
    
    @Binding var isShowingModal: Bool
    @State private var selectedNumber: Int = 250
    @State private var selectedDrink: String = ""
    @State private var isImageDisabled: Bool = true
    @State private var isPressedImpact: Bool = false
    @State private var normDrink: Double = 2000
    @State private var unit: Int = 0
    
    @State private var isNormExceeding = false
    @Binding var isNormExceedingShowModal: Bool
    @Binding var isNormDoneShowModal: Bool
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundViewColor
                    .ignoresSafeArea()
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white)
                    GeometryReader { geometry in
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(drinkProvider.drinks.indices, id: \.self) { index in
                                        Button(action: {
                                            selectedDrink = drinkProvider.drinks[index].key
                                            isImageDisabled = false
                                        }) {
                                            VStack(spacing: 10) {
                                                Image(selectedDrink == drinkProvider.drinks[index].key
                                                      ? "\(drinkProvider.drinks[index].key)Highlighted"
                                                      : drinkProvider.drinks[index].key)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: sizeButton(for: geometry.size.width), height: sizeButton(for: geometry.size.width))
                                                Text(drinkProvider.drinks[index].name)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .padding(.vertical, index > 5 && !purchaseManager.hasPremium ? 5 : 0)
                                        .disabled(index > 5 && !purchaseManager.hasPremium)
                                        .blur(radius: index > 5 && !purchaseManager.hasPremium ? 3 : 0)
                                        .overlay {
                                            if index > 5 && !purchaseManager.hasPremium {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .blur(radius: 3)
                                                        .foregroundStyle(.white)
                                                        .opacity(0.1)
                                                    VStack {
                                                        Image(systemName: "lock")
                                                            .font(Constants.Design.Fonts.BodyLargeFont)
                                                        VStack {
                                                            Text("Премиум-")
                                                                .font(Constants.Design.Fonts.BodyMiniFont)
                                                                .multilineTextAlignment(.center)
                                                            Text("доступ")
                                                                .font(Constants.Design.Fonts.BodyMiniFont)
                                                                .multilineTextAlignment(.center)
                                                        }
                                                    }
                                                    .foregroundStyle(.white)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(.white)
                            VStack {
                                Text("Выберите объём:")
                                    .font(.custom("Palatino", size: 19))
                                    .foregroundStyle(.white)
                                    .padding(.top, 30)
                                Picker("Выберите объём:", selection: $selectedNumber) {
                                    ForEach(Array(stride(
                                        from: profile[0].unit == 0 ? 50 : 2,
                                        to: profile[0].unit == 0 ? 2050 : 70,
                                        by: profile[0].unit == 0 ? 50 : 2
                                    )), id: \.self) { number in
                                        Text("\(number)")
                                            .tag(number)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: sizePicker(for: geometry.size.width))
                                Button("Добавить напиток") {
                                    isPressedImpact.toggle()
                                    drinkWater(amountDrink: selectedNumber)
                                    isShowingModal = false
                                }
                                .sensoryFeedback(.impact, trigger: isPressedImpact)
                                .disabled(isImageDisabled)
                                .font(.custom("Palatino", size: 17))
                                .padding(.horizontal, 27)
                                .padding(.vertical, 12)
                                .foregroundStyle(!isImageDisabled ? .white : Color(white: 1, opacity: 0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(!isImageDisabled ? .white : Color(white: 1, opacity: 0.5), lineWidth: 1)
                                )
                            }
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                if networkMonitor.isConnected {
                    AppMetrica.reportEvent(name: "OpenView", parameters: ["CustomAmountView": ""])
                }
                
                unit = profile[0].unit
                
                if unit == 0 {
                    normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                } else {
                    normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Выберите напиток")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image("CloseButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
    }
}

extension CustomAmountView {
    private func sizeButton(for width: CGFloat) -> CGFloat {
        return width > 402 ? 80 : 70
    }
    
    private func sizePicker(for width: CGFloat) -> CGFloat {
        return width > 402 ? 150 : 100
    }
    
    private func drinkWater(amountDrink: Int) {
        let now = Date()
        let todayID = now.yearMonthDay
        
        DispatchQueue.main.async {
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: amountDrink)
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: amountDrink, dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(Double(amountDrink) * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (Double(amountDrink) * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0) / normDrink * 100))
            
            let percentDrink: Double = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
            let amountDrinkingOfTheDay = dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.amountDrinkOfTheDay ?? 0
            let lastNameDrink = profile[0].lastNameDrink
            WidgetManager.sendDataToWidget(normDrink, amountDrinkingOfTheDay, percentDrink, lastNameDrink, unit, purchaseManager.hasPremium)
            
            let dateLastDrink = Date().dateFormatForWidgetAndWatch
            let amountUnit = unit == 0 ? "250" : "8"
            let iPhoneAppContext = ["normDrink": String(Int(normDrink)),
                                    "amountDrink": String(amountDrinkingOfTheDay),
                                    "percentDrink": String(Int(percentDrink)),
                                    "amountUnit": amountUnit,
                                    "unit": unit,
                                    "dateLastDrink": dateLastDrink,
                                    "isPremium": purchaseManager.hasPremium] as [String: Any]
            PhoneSessionManager.shared.sendAppContextToWatch(iPhoneAppContext)
            PhoneSessionManager.shared.transferCurrentComplicationUserInfo(iPhoneAppContext)
            
            // Проверка на превышение нормы
            if percentDrink >= 140 && !isNormExceeding {
                isNormExceeding = true
                isNormExceedingShowModal = true
                userDefaultsManager.setValueForUserDefaults(true, "normExceeding")
            }
            
            // Проверка на достижение нормы
            let normDone = userDefaultsManager.getBoolValueForUserDefaults("normDone") ?? false
            if percentDrink >= 100 && !normDone {
                if let numberOfTheNorm = userDefaultsManager.getValueForUserDefaults("numberNorm") {
                    userDefaultsManager.setValueForUserDefaults(numberOfTheNorm + 1, "numberNorm")
                }
                userDefaultsManager.setValueForUserDefaults(true, "normDone")
                
                let calendar = Calendar.current
                let isRemindersEnabled = reminder[0].reminderEnabled
                let interval = reminder[0].intervalReminder
                let nextStartDay = calendar.date(byAdding: .day, value: 1, to: reminder[0].startTimeReminder)!
                let nextEndDay = calendar.date(byAdding: .day, value: 1, to: reminder[0].finishTimeReminder)!
                remindersViewModel.updateReminders(reminder: reminder, startTimeReminder: nextStartDay)
                remindersViewModel.updateReminders(reminder: reminder, finishTimeReminder: nextEndDay)
                let remindersView = RemindersView(isRemindersEnabled: .constant(isRemindersEnabled))
                remindersView.disableRemindersForToday(startDay: nextStartDay, endDay: nextEndDay, interval: interval)
                
                isNormDoneShowModal = true
            }
            
            if userDefaultsManager.isAuthorizationHealthKit {
                let amountOfTheHealthKit = Double(amountDrink) * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0)
                healthKitManager.saveWaterIntake(amount: amountOfTheHealthKit, date: now, unit: unit) { (success, error) in
                    let successMessage = "Water intake saved successfully"
                    let errorMessage = "Error saving water intake: \(error?.localizedDescription ?? "Unknown error")"
                    if success {print(successMessage) } else { print(errorMessage) }
                }
            }
        }
    }
}

#Preview {
    CustomAmountView(isShowingModal: .constant(false), isNormExceedingShowModal: .constant(false), isNormDoneShowModal: .constant(false))
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
        .environmentObject(DrinkDataProvider())
}
