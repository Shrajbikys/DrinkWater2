//
//  MainView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData
import AppMetricaCore

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var profileViewModel = ProfileViewModel()
    var dataDrinkingViewModel = DataDrinkingViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var lastAmountDrink: Int = 250
    @State private var lastNameDrink: String = "Water"
    @State private var normDrink: Double = 2000
    @State private var normDrinkLabel:  String = ""
    @State private var unit: Int = 0
    
    @State private var stopNorm = 0
    @State private var isShowingModal = false
    @State private var isAchievementShowingModal = false
    @State private var showAchievementsModal = false
    @State private var isShowingCancelButton = false
    @State private var isDrinkedPressed = false
    @State private var isPressedImpact = false
    @State private var isNormExceeding = false
    @State private var isNormExceedingModal = false
    @State private var isAnimationAchievement = false
    @State private var isShowMainWidthView = false
    @State private var path = NavigationPath()
    
    private let backgroundExternalCircleColor: Color = Color(#colorLiteral(red: 0.631372549, green: 0.7921568627, blue: 0.9725490196, alpha: 1))
    private let backgroundInternalCircleColor: Color = Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 1))
    private let backgroundDrinkValueColor: Color = Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 1))
    private let backgroundDrinkHeaderValueColor: Color = Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 0.6))
    
    @State private var isPurchaseViewModal = false
    
    let hydration: [String: Double] = Constants.Back.Drink.hydration
    
    enum DrinkAction {
        case drink
        case cancel
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("BackgroundNew")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                VStack {
                    GeometryReader { geometry in
                        ZStack {
                            // Базовый полукруглый путь для фона
                            Circle()
                                .trim(from: 0.5, to: 1.0)
                                .stroke(backgroundExternalCircleColor, lineWidth: 20)
                                .rotationEffect(.degrees(270))
                            // Заполняющаяся часть
                            Circle()
                                .trim(from: 0.5, to: 0.5 + ((dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking ?? 0) / 100) / 2)
                                .stroke(backgroundInternalCircleColor, lineWidth: 15)
                                .rotationEffect(.degrees(270))
                                .animation(.easeInOut(duration: 1.0), value: (dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking ?? 0) / 100)
                        }
                        .frame(width: geometry.size.width * 1.7, height: geometry.size.width * 1.7)
                        .position(x: geometry.size.width / 0.99, y: geometry.size.height / 3)
                    }
                }
                GeometryReader { geometry in
                    HStack(alignment: .center) {
                        if dataDrinkingViewModel.isAvailiableRecordOfTheCurrentDay(dataDrinking: dataDrinking) {
                            Button(action: {
                                isPressedImpact.toggle()
                                drinkWaterAction(action: .cancel, nameDrink: nil, amountDrink: nil)
                            }) {
                                Image("cancelButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            }
                            .sensoryFeedback(.impact, trigger: isPressedImpact)
                        }
                        Spacer()
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image("settingsButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 15)
                }
                GeometryReader { geometry in
                    VStack(spacing: 10) {
                        Text("Выпито")
                            .font(Constants.Design.Fonts.BodyMainFont)
                        let amountDrinkOfTheDay = Double(dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.amountDrinkOfTheDay ?? 0)
                        Text("\(unit == 0 ? amountDrinkOfTheDay.toStringMilli : amountDrinkOfTheDay.toStringOunces)")
                            .contentTransition(.numericText(value: amountDrinkOfTheDay))
                            .font(Constants.Design.Fonts.BodyTitle1Font)
                            .bold()
                            .animation(.easeInOut, value: amountDrinkOfTheDay)
                    }
                    .foregroundStyle(.white)
                    .position(x: geometry.size.width / 1.45, y: geometry.size.height / 5)
                }
                GeometryReader { geometry in
                    VStack(spacing: 7) {
                        Text("Цель")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(backgroundDrinkHeaderValueColor)
                        Text("\(normDrinkLabel)")
                            .font(Constants.Design.Fonts.BodyMainFont)
                            .foregroundStyle(backgroundDrinkValueColor)
                    }
                    .position(x: geometry.size.width / 2.7, y: geometry.size.height / 2.7)
                }
                GeometryReader { geometry in
                    Button(action: {
                        if purchaseManager.hasPremium {
                            AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "AchievementsView"])
                            isAchievementShowingModal = true
                        } else {
                            AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "AchievementsPurchaseView"])
                            isPurchaseViewModal = true
                        }
                    }) {
                        Image("Winning")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 55, height: 55)
                            .rotationEffect(.degrees(isAnimationAchievement ? 0 : 5))
                            .animation(.easeInOut(duration: 0.2).repeatCount(15, autoreverses: true), value: isAnimationAchievement)
                            .onAppear {
                                isAnimationAchievement = true
                            }
                    }
                    .sheet(isPresented: $isAchievementShowingModal) {
                        AchievementsView(isAchievementShowingModal: $isAchievementShowingModal)
                    }
                    .position(x: geometry.size.width / 10, y: geometry.size.height / 2)
                }
                GeometryReader { geometry in
                    Button {
                        if !userDefaultsManager.isFirstSignWidth {
                            let dataWeight = DataWeight()
                            let weight = profile[0].weightKg
                            dataWeight.weight = weight
                            dataWeight.goal = weight
                            modelContext.insert(dataWeight)
                        }
                        if purchaseManager.hasPremium {
                            AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "MainWeightView"])
                            isAchievementShowingModal = true
                        } else {
                            AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "MainWeightPurchaseView"])
                            isPurchaseViewModal = true
                        }
                        isShowMainWidthView = true
                    } label: {
                        Image("WeightScale")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isAnimationAchievement ? 1 : 0.9)
                            .animation(.easeInOut(duration: 0.2).repeatCount(15, autoreverses: true), value: isAnimationAchievement)
                            .onAppear {
                                isAnimationAchievement = true
                            }
                    }
                    
                    .sheet(isPresented: $isShowMainWidthView, onDismiss: {
                        unit = profile[0].unit
                        if unit == 0 {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                        } else {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                        }
                        normDrinkLabel = unit == 0 ? normDrink.toStringMilli : normDrink.toStringOunces
                        
                    }, content: {
                        MainWeightView(unit: unit)
                    })
                    .position(x: geometry.size.width / 10, y: geometry.size.height / 1.75)
                }
                GeometryReader { geometry in
                    VStack(spacing: 7) {
                        Text("Завершено")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(backgroundDrinkHeaderValueColor)
                        let percentDrink = dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
                        Text("\(Int(percentDrink).formatted(.percent))")
                            .contentTransition(.numericText(value: percentDrink))
                            .font(Constants.Design.Fonts.BodyMainFont)
                            .foregroundStyle(backgroundDrinkValueColor)
                            .animation(.easeInOut, value: percentDrink)
                    }
                    .position(x: geometry.size.width / 1.8, y: geometry.size.height / 1.9)
                }
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: -20) {
                        HStack(alignment: .center) {
                            Button(action: {
                                isShowingModal = true
                                AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "SelectDrinkView"])
                            }) {
                                Image("\(profile[0].lastNameDrink)Main")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                            }
                            Spacer()
                            Button(action: {
                                isDrinkedPressed = true
                                isPressedImpact.toggle()
                                drinkWaterAction(action: .drink, nameDrink: nil, amountDrink: nil)
                            }) {
                                VStack {
                                    Image("drinkWateButton")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                    Text(profile[0].unit == 0 ? Double(profile[0].lastAmountDrink).toStringMilli : Double(profile[0].lastAmountDrink).toStringOunces)
                                        .font(Constants.Design.Fonts.BodyMediumFont)
                                        .foregroundStyle(.white)
                                }
                            }
                            .sensoryFeedback(.impact, trigger: isPressedImpact)
                            .scaleEffect(isDrinkedPressed ? 0.5 : 1.0)
                            .animation(.linear(duration: 0.2), value: isDrinkedPressed)
                            .alert("Предупреждение", isPresented: $isNormExceedingModal) {
                                Button(role: .cancel) {} label: {
                                    Text("OK")
                                }
                            } message: {
                                Text("Не рекомендуется превышать объём ежедневной нормы. Это может вызвать недомогание и повышенную утомляемость.")
                            }
                            Spacer()
                            NavigationLink {
                                StatisticsView()
                            } label: {
                                Image("historyButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .padding(.bottom, 50)
                        .padding(.horizontal, 30)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 1.1)
                    }
                }
            }
            .blur(radius: isShowingModal ? 10 : 0)
            .sheet(isPresented: $isShowingModal) {
                SelectDrinkView(isShowingModal: $isShowingModal)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $isPurchaseViewModal) {
                PurchaseView(isPurchaseViewModal: $isPurchaseViewModal)
            }
            .onChange(of: PhoneSessionManager.shared.idOperation, {
                let drinkName = PhoneSessionManager.shared.nameDrink
                let amountDrink = PhoneSessionManager.shared.amountDrink
                AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "DrinkWaterFromWatch"])
                drinkWaterAction(action: .drink, nameDrink: drinkName, amountDrink: Int(amountDrink))
            })
            .onAppear {
                AppMetrica.reportEvent(name: "OpenView", parameters: ["MainView": ""])
                
                if !dataDrinkingOfTheDay.contains(where: { $0.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay } ) {
                    userDefaultsManager.setValueForUserDefaults(false, "normDone")
                    userDefaultsManager.setValueForUserDefaults(false, "normExceeding")
                }
                
                if let isNormExceeding = userDefaultsManager.getBoolValueForUserDefaults("normExceeding") {
                    self.isNormExceeding = isNormExceeding
                }
                
                lastAmountDrink = profile[0].lastAmountDrink
                lastNameDrink = profile[0].lastNameDrink
                unit = profile[0].unit
                
                if unit == 0 {
                    normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                } else {
                    normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                }
                
                stopNorm = unit == 0 ? 4000 : 140
                
                normDrinkLabel = unit == 0 ? normDrink.toStringMilli : normDrink.toStringOunces
            }
            .onOpenURL { url in
                if url.scheme == "drinkwaterapp" {
                    AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "DrinkWaterFromWidget"])
                    drinkWaterAction(action: .drink, nameDrink: nil, amountDrink: Int(url.host!))
                }
            }
            .animation(.easeInOut, value: isShowingModal)
            .blur(radius: showAchievementsModal ? 10 : 0)
            .overlay(content: {
                if showAchievementsModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showAchievementsModal = false
                            }
                        }
                    AchievementsModalView(showAchievementsModal: $showAchievementsModal, imageAchievement: "Winning", nameAchievementFirst: "Поздравляем!", nameAchievementSecond: "Вы достигли цели!")
                }
            })
        }
        .navigationBarBackButtonHidden()
    }
    
    private func sendDataToWidgetAndWatch(amountDrinkingOfTheDay: Int, percentDrink: Double) {
        let isPremium = purchaseManager.hasPremium
        WidgetManager.sendDataToWidget(normDrink, amountDrinkingOfTheDay, percentDrink, lastNameDrink, unit, isPremium)
        
        let dateLastDrink = Date().dateFormatForWidgetAndWatch
        let amountUnit = unit == 0 ? "250" : "8"
        let iPhoneAppContext = ["normDrink": String(Int(normDrink)),
                                "amountDrink": String(amountDrinkingOfTheDay),
                                "percentDrink": String(Int(percentDrink)),
                                "amountUnit": amountUnit,
                                "unit": unit,
                                "dateLastDrink": dateLastDrink,
                                "isPremium": isPremium] as [String: Any]
        PhoneSessionManager.shared.sendAppContextToWatch(iPhoneAppContext)
        PhoneSessionManager.shared.transferCurrentComplicationUserInfo(iPhoneAppContext)
    }
    
    private func drinkWater(lastNameDrink: String, lastAmountDrink: Int, amountDrinkOfTheDay: Int, percentDrinking: Double) {
        let now = Date()
        let todayID = now.yearMonthDay
        
        profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink)
        dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: lastNameDrink, amountDrink: lastAmountDrink, dateDrink: now)
        dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: amountDrinkOfTheDay, dateDrinkOfTheDay: now, percentDrinking: percentDrinking)
        
        AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "DrinkWater"])
        DispatchQueue.main.async {
            isDrinkedPressed = false
            
            // Сохраняем данные в HealthKit, если разрешение получено
            if userDefaultsManager.isAuthorizationHealthKit {
                healthKitManager.saveWaterIntake(amount: Double(amountDrinkOfTheDay), date: now, unit: unit) { (success, error) in
                    let successMessage = "Water intake saved successfully"
                    let errorMessage = "Error saving water intake: \(error?.localizedDescription ?? "Unknown error")"
                    if success {print(successMessage) } else { print(errorMessage) }
                }
            }
            
            // Получаем актуальные данные для отправки в виджет и на часы
            let amountDrinkingOfTheDay: Int = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.amountDrinkOfTheDay ?? 0
            let percentDrink: Double = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
            
            // Отправка данных на виджет и Apple Watch
            sendDataToWidgetAndWatch(amountDrinkingOfTheDay: amountDrinkingOfTheDay, percentDrink: percentDrink)
            
            // Проверка на превышение нормы
            let percentDrinkNew: Double = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
            if percentDrinkNew >= 140 && !isNormExceeding {
                isNormExceeding = true
                isNormExceedingModal = true
                userDefaultsManager.setValueForUserDefaults(true, "normExceeding")
            }
            
            // Проверка на достижение нормы
            let normDone = userDefaultsManager.getBoolValueForUserDefaults("normDone") ?? false
            if percentDrinkNew >= 100 && !normDone {
                if let numberOfTheNorm = userDefaultsManager.getValueForUserDefaults("numberNorm") {
                    userDefaultsManager.setValueForUserDefaults(numberOfTheNorm + 1, "numberNorm")
                }
                userDefaultsManager.setValueForUserDefaults(true, "normDone")
                showAchievementsModal = true
            }
        }
    }
    
    private func cancelDrinkWater(amountDrinkOfTheDay: Int, percentDrinking: Double, lastNameDrinkProfile: String, lastAmountDrinkProfile: Int) {
        let now = Date()
        let todayID = now.yearMonthDay
        
        dataDrinkingOfTheDayViewModel.cancelDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
        profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: lastNameDrinkProfile, lastAmountDrink: lastAmountDrinkProfile)
        dataDrinkingViewModel.deleteItemDataDrinking(modelContext: modelContext, itemDataDrinking: dataDrinking.last!)
        
        AppMetrica.reportEvent(name: "MainView", parameters: ["Press button": "CancelDrinkWater"])
        DispatchQueue.main.async {
            // Сохраняем данные в HealthKit, если разрешение получено
            if userDefaultsManager.isAuthorizationHealthKit {
                healthKitManager.deleteWaterIntake(date: dataDrinking.last!.dateDrink)
            }
            
            // Получаем актуальные данные для отправки в виджет и на часы
            let amountDrinkingOfTheDay: Int = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.amountDrinkOfTheDay ?? 0
            let percentDrink: Double = dataDrinkingOfTheDay.first(where: { $0.dayID == todayID } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
            
            // Отправка данных на виджет и Apple Watch
            sendDataToWidgetAndWatch(amountDrinkingOfTheDay: amountDrinkingOfTheDay, percentDrink: percentDrink)
        }
    }
    
    private func drinkWaterAction(action: DrinkAction, nameDrink: String?, amountDrink: Int?) {
        lastNameDrink = profile[0].lastNameDrink
        lastAmountDrink = profile[0].lastAmountDrink
        
        if let nameDrink = nameDrink {
            lastNameDrink = nameDrink
        }
        
        var amountDrinkOfTheDay = Int(Double(lastAmountDrink) * (hydration[lastNameDrink] ?? 1.0))
        if let amountDrink = amountDrink {
            lastAmountDrink = amountDrink
            amountDrinkOfTheDay = Int(Double(amountDrink) * (hydration[lastNameDrink] ?? 1.0))
        }
        
        let percentDrinking = (Double(lastAmountDrink) * (hydration[lastNameDrink] ?? 1.0)) / normDrink * 100
        let lastNameDrinkProfile = dataDrinking.count > 1 ? dataDrinking[dataDrinking.count - 2].nameDrink : dataDrinking.last?.nameDrink ?? "Water"
        let lastAmountDrinkProfile = dataDrinking.count > 1 ? dataDrinking[dataDrinking.count - 2].amountDrink : dataDrinking.last?.amountDrink ?? 100
        
        switch action {
        case .drink:
            if dataDrinkingOfTheDay.last?.amountDrinkOfTheDay ?? 0 < stopNorm {
                drinkWater(lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
            } else {
                isDrinkedPressed = false
            }
        case .cancel:
            cancelDrinkWater(amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking, lastNameDrinkProfile: lastNameDrinkProfile, lastAmountDrinkProfile: lastAmountDrinkProfile)
        }
    }
}

#Preview {
    MainView()
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}