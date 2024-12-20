//
//  SelectDrinkView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData
import AppMetricaCore

struct SelectDrinkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    @EnvironmentObject var drinkProvider: DrinkDataProvider
    
    @Binding var isShowingModal: Bool
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    @Query var reminder: [Reminder]
    
    @State private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State private var networkMonitor = NetworkMonitor()
    
    @State var profileViewModel = ProfileViewModel()
    @State var dataDrinkingViewModel = DataDrinkingViewModel()
    @State var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    
    private let nameButtonCustomAmountMl: [Double] = [250, 300, 350, 500]
    private let nameButtonCustomAmountOz: [Double] = [8, 10, 11, 16]

    @State private var normDrink: Double = 2000
    @State private var unit: Int = 0
    
    @State private var selectedDrink: String = ""
    @State private var isPressedImpact: Bool = false
    
    @State private var isNormExceeding = false
    @Binding var isNormExceedingShowModal: Bool
    @Binding var isNormDoneShowModal: Bool
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    private let backgroundSelectAmountCircleColor = Color(#colorLiteral(red: 0.5921568627, green: 0.7921568627, blue: 0.9882352941, alpha: 0.35))
    
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
                            ZStack {
                                RoundedRectangle(cornerRadius: 30.0)
                                    .foregroundStyle(backgroundSelectAmountCircleColor)
                                    .frame(height: heightBackgroundButtons(for: geometry.size.width))
                                    .padding(.horizontal, 10)
                                HStack(spacing: spacingBetweenButtons(for: geometry.size.width)) {
                                    ForEach(0...4, id: \.self) { index in
                                        if index < 4 {
                                            Button(action: {
                                                drinkWater(index: index)
                                                isPressedImpact.toggle()
                                                dismiss()
                                            }, label: {
                                                ZStack(alignment: .center) {
                                                    Image("BlankAmount")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: sizeButton(for: geometry.size.width), height: sizeButton(for: geometry.size.width))
                                                    Text("\(profile[0].unit == 0 ? nameButtonCustomAmountMl[index].toStringMilli : nameButtonCustomAmountOz[index].toStringOunces)")
                                                        .font(.caption)
                                                        .foregroundStyle(.white)
                                                }
                                            })
                                            .sensoryFeedback(.impact, trigger: isPressedImpact)
                                        } else {
                                            NavigationLink {
                                                CustomAmountView(isShowingModal: $isShowingModal, isNormExceedingShowModal: .constant(false), isNormDoneShowModal: .constant(false))
                                            } label: {
                                                ZStack(alignment: .center) {
                                                    Image("BlankAmount")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: sizeButton(for: geometry.size.width), height: sizeButton(for: geometry.size.width))
                                                    Text("+")
                                                        .font(.title)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(width: geometry.size.width, height: 85)
                            ScrollView {
                                LazyVStack(spacing: 15) {
                                    ForEach(drinkProvider.drinks.indices, id: \.self) { index in
                                        if index % 3 == 0 {
                                            HStack(spacing: 25) {
                                                ForEach(index..<min(index + 3, drinkProvider.drinks.count), id: \.self) { innerIndex in
                                                    VStack {
                                                        ZStack {
                                                            Button(action: {
                                                                selectedDrink = drinkProvider.drinks[innerIndex].key
                                                            }) {
                                                                VStack(spacing: 10) {
                                                                    Image(selectedDrink == drinkProvider.drinks[innerIndex].key
                                                                          ? "\(drinkProvider.drinks[innerIndex].key)Highlighted"
                                                                          : drinkProvider.drinks[innerIndex].key)
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    Text(drinkProvider.drinks[innerIndex].name)
                                                                        .font(.subheadline)
                                                                        .foregroundStyle(.white)
                                                                }
                                                            }
                                                            .disabled(innerIndex > 5 && !purchaseManager.hasPremium)
                                                            .blur(radius: innerIndex > 5 && !purchaseManager.hasPremium ? 3 : 0)
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(innerIndex > 5 && !purchaseManager.hasPremium ? 5 : 0)
                                                    .overlay {
                                                        if innerIndex > 5 && !purchaseManager.hasPremium {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .blur(radius: 3)
                                                                    .foregroundStyle(.white)
                                                                    .opacity(0.1)
                                                                VStack {
                                                                    Image(systemName: "lock")
                                                                        .font(Constants.Design.Fonts.BodyLargeFont)
                                                                    Text("Премиум-доступ")
                                                                        .font(Constants.Design.Fonts.BodySmallFont)
                                                                        .multilineTextAlignment(.center)
                                                                }
                                                                .foregroundStyle(.white)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 25)
                                        }
                                    }
                                }
                            }
                            .frame(width: geometry.size.width)
                            .padding(.top, 5)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .onAppear {
                        if networkMonitor.isConnected {
                            AppMetrica.reportEvent(name: "OpenView", parameters: ["SelectDrinkView": ""])
                        }
                        
                        DispatchQueue.main.async {
                            unit = profile[0].unit
                            selectedDrink = profile[0].lastNameDrink
                        }
                        
                        if unit == 0 {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                        } else {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Выберите объём и напиток")
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

extension SelectDrinkView {
    private func spacingBetweenButtons(for width: CGFloat) -> CGFloat {
        return width > 402 ? 12 : 10
    }
    
    private func sizeButton(for width: CGFloat) -> CGFloat {
        return width > 402 ? 70 : 60
    }
    
    private func heightBackgroundButtons(for width: CGFloat) -> CGFloat {
        return width > 402 ? 85 : 75
    }
    
    private func drinkWater(index: Int) {
        let now = Date()
        let todayID = now.yearMonthDay
        
        DispatchQueue.main.async {
            let amountDrink = unit == 0 ? nameButtonCustomAmountMl[index] : nameButtonCustomAmountOz[index]
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: Int(amountDrink))
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: Int(amountDrink), dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(amountDrink * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (amountDrink * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0) / normDrink * 100))
            
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
                let amountOfTheHealthKit = amountDrink * (drinkProvider.hydration(forKey: selectedDrink) ?? 1.0)
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
    SelectDrinkView(isShowingModal: .constant(false), isNormExceedingShowModal: .constant(false), isNormDoneShowModal: .constant(false))
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
        .environmentObject(DrinkDataProvider())
}
