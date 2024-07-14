//
//  MainView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var profileViewModel = ProfileViewModel()
    var dataDrinkingViewModel = DataDrinkingViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var  lastAmountDrink: Int = 250
    @State private var  lastNameDrink: String = "Water"
    @State private var  autoNormMl: Double = 2000
    @State private var  unit: Int = 0
    
    @State private var unitVolume = "мл."
    @State private var stopNorm = 0
    @State private var isShowingModal = false
    @State private var isAchievementShowingModal = false
    @State private var showAchievementsModal = false
    @State private var isShowingCancelButton = false
    @State private var isDrinkedPressed = false
    @State private var isPressedImpact = false
    @State private var isNormExceeding = false
    @State private var isStopNorm = false
    
    let hydration: [String: Double] = ["Water": 1.0, "Coffee": 0.8, "Tea": 0.9, "Milk": 0.9, "Juice": 0.8, "Soda": 0.9, "Cocoa": 0.7, "Smoothie": 0.3, "Yogurt": 0.5, "Beer": -0.6, "NonalcoholicBeer": 0.6, "Wine": -1.6]
    
    enum DrinkAction {
        case drink
        case cancel
    }
    
    var body: some View {
        NavigationStack {
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
                                .stroke(Color(#colorLiteral(red: 0.631372549, green: 0.7921568627, blue: 0.9725490196, alpha: 1)), lineWidth: 20)
                                .rotationEffect(.degrees(270))
                            // Заполняющаяся часть
                            Circle()
                                .trim(from: 0.5, to: 0.5 + ((dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking ?? 0) / 100) / 2)
                                .stroke(Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 1)), lineWidth: 15)
                                .rotationEffect(.degrees(270))
                                .animation(.easeInOut(duration: 1.0), value: (dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking ?? 0) / 100)
                        }
                        .frame(width: 645, height: 645)
                        .position(x: geometry.size.width / 0.99, y: geometry.size.height / 3)
                    }
                }
                GeometryReader { geometry in
                    HStack(alignment: .center) {
                        if isShowingCancelButton {
                            Button(action: {
                                isPressedImpact.toggle()
                                drinkWaterAction(action: .cancel)
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
                            .font(Constants.Design.AppFont.BodyMainFont)
                        Text("\(Int(dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.amountDrinkOfTheDay ?? 0)) мл")
                            .font(Constants.Design.AppFont.BodyTitle1Font)
                            .bold()
                    }
                    .foregroundStyle(.white)
                    .position(x: geometry.size.width / 1.45, y: geometry.size.height / 5)
                }
                GeometryReader { geometry in
                    VStack(spacing: 7) {
                        Text("Цель")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                            .foregroundStyle(Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 0.6)))
                        Text("\(Int(profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl))")
                            .font(Constants.Design.AppFont.BodyMainFont)
                            .foregroundStyle(Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 1)))
                    }
                    .position(x: geometry.size.width / 2.7, y: geometry.size.height / 2.7)
                }
                GeometryReader { geometry in
                    Button(action: {
                        isAchievementShowingModal = true
                    }) {
                        Image("1DayAchiev")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                    }
                    .sheet(isPresented: $isAchievementShowingModal) {
                        AchievementsView(isAchievementShowingModal: $isAchievementShowingModal)
                    }
                    .position(x: geometry.size.width / 10, y: geometry.size.height / 2)
                }
                GeometryReader { geometry in
                    VStack(spacing: 7) {
                        Text("Завершено")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                            .foregroundStyle(Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 0.6)))
                        Text("\(Int(dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0))%")
                            .font(Constants.Design.AppFont.BodyMainFont)
                            .foregroundStyle(Color(#colorLiteral(red: 0.4352941176, green: 0.6196078431, blue: 0.831372549, alpha: 1)))
                    }
                    .position(x: geometry.size.width / 1.8, y: geometry.size.height / 1.9)
                }
                GeometryReader { geometry in
                    HStack(alignment: .center) {
                        Button(action: {
                            isShowingModal = true
                        }) {
                            Image("WaterMain")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                        }
                        Spacer()
                        Button(action: {
                            isDrinkedPressed = true
                            isPressedImpact.toggle()
                            drinkWaterAction(action: .drink)
                        }) {
                            Image("drinkWateButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        }
                        .sensoryFeedback(.impact, trigger: isPressedImpact)
                        .scaleEffect(isDrinkedPressed ? 0.5 : 1.0)
                        .animation(.linear(duration: 0.2), value: isDrinkedPressed)
                        .alert("Предупреждение", isPresented: $isNormExceeding) {
                            Button(role: .cancel) {} label: {
                                Text("OK")
                            }
                        } message: {
                            Text("Не рекомендуется превышать объём ежедневной нормы. Это может вызвать недомогание и повышенную утомляемость.")
                        }
                        .alert("Внимание", isPresented: $isStopNorm) {
                            Button(role: .cancel) {
                                isStopNorm = false
                            } label: {
                                Text("OK")
                            }
                        } message: {
                            Text("Не рекомендуется пить более \(stopNorm) \(unitVolume) в день!")
                        }
                        Spacer()
                        NavigationLink {
                            StatisticsDrinkView()
                        } label: {
                            Image("historyButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding()
                    .padding(.bottom, 50)
                    .padding(.horizontal)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 1.1)
                }
            }
            .blur(radius: isShowingModal ? 10 : 0)
            .sheet(isPresented: $isShowingModal) {
                SelectDrinkView(isShowingModal: $isShowingModal)
                    .presentationDetents([.medium])
            }
            .onAppear {
                if let dataDrinkingOfTheDayLast  = dataDrinkingOfTheDay.last,  dataDrinkingOfTheDayLast.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay {
                    isShowingCancelButton = dataDrinkingOfTheDayLast.amountDrinkOfTheDay > 0 ? true : false
                }
                if !dataDrinkingOfTheDay.contains(where: { $0.dateDrinkOfTheDay.yearMonthDay == Date().yearMonthDay } ) {
                    userDefaultsManager.setValueForUserDefaults(false, "normDone")
                    userDefaultsManager.setValueForUserDefaults(false, "normExceeding")
                }
                
                lastAmountDrink = profile[0].lastAmountDrink
                lastNameDrink = profile[0].lastNameDrink
                autoNormMl = profile[0].autoNormMl
                unit = profile[0].unit
                
                stopNorm = unit == 0 ? 4000 : 140
                unitVolume = unit == 0 ? "мл." : "унц."
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
    
    private func drinkWater(lastNameDrink: String, lastAmountDrink: Int, unit: Int,  amountDrinkOfTheDay: Int, percentDrinking: Double) {
        let now = Date()
        DispatchQueue.main.async {
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: lastNameDrink, amountDrink: lastAmountDrink, dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: amountDrinkOfTheDay, dateDrinkOfTheDay: now, percentDrinking: percentDrinking)
            
            isShowingCancelButton = dataDrinkingOfTheDay.last?.amountDrinkOfTheDay ?? 0 > 0 ? true : false
            isDrinkedPressed = false
            
            let percentDrinkNew = (dataDrinkingOfTheDay.last?.percentDrinking ?? 0).rounded(.toNearestOrAwayFromZero)
            
            if userDefaultsManager.isAuthorizationHealthKit {
                healthKitManager.saveWaterIntake(amount: Double(amountDrinkOfTheDay), date: now, unit: unit) { (success, error) in
                    let successMessage = "Water intake saved successfully"
                    let errorMessage = "Error saving water intake: \(error?.localizedDescription ?? "Unknown error")"
                    if success {print(successMessage) } else { print(errorMessage) }
                }
            }
            
            if percentDrinkNew >= 140 && !isNormExceeding {
                isNormExceeding = true
                userDefaultsManager.setValueForUserDefaults(true, "normExceeding")
                isNormExceeding = false
            }
            
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
        DispatchQueue.main.async {
            dataDrinkingOfTheDayViewModel.cancelDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: lastNameDrinkProfile, lastAmountDrink: lastAmountDrinkProfile)
            dataDrinkingViewModel.deleteItemDataDrinking(modelContext: modelContext, itemDataDrinking: dataDrinking.last!)
            
            isShowingCancelButton = dataDrinkingOfTheDay.last!.amountDrinkOfTheDay > 0 ? true : false
            
            if userDefaultsManager.isAuthorizationHealthKit {
                healthKitManager.deleteWaterIntake(date: dataDrinking.last!.dateDrink)
            }
        }
    }
    
    private func drinkWaterAction(action: DrinkAction) {
        let amountDrinkOfTheDay = Int(Double(lastAmountDrink) * (hydration[lastNameDrink] ?? 1.0))
        let percentDrinking = (Double(lastAmountDrink) * (hydration[lastNameDrink] ?? 1.0)) / autoNormMl * 100
        let lastNameDrinkProfile = dataDrinking.count > 1 ? dataDrinking[dataDrinking.count - 2].nameDrink : dataDrinking.last?.nameDrink ?? "Water"
        let lastAmountDrinkProfile = dataDrinking.count > 1 ? dataDrinking[dataDrinking.count - 2].amountDrink : dataDrinking.last?.amountDrink ?? 100
        let isAvailiableRecordOfTheCurrentDay = dataDrinkingOfTheDayViewModel.isAvailiableRecordOfTheCurrentDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay)
        
        switch action {
        case .drink:
            if dataDrinkingOfTheDay.isEmpty {
                drinkWater(lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink, unit: unit, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
            } else {
                if isAvailiableRecordOfTheCurrentDay {
                    if dataDrinkingOfTheDay.last!.amountDrinkOfTheDay < stopNorm {
                        drinkWater(lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink, unit: unit, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
                    } else if dataDrinkingOfTheDay.last!.amountDrinkOfTheDay >= stopNorm {
                        isStopNorm = true
                        isDrinkedPressed = false
                    }
                } else {
                    drinkWater(lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink, unit: unit, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
                }
                
                
//            } else {
//                if let dataDrinkingOfTheDayViewItem = dataDrinkingOfTheDayViewModel.getLastRecordOfTheCurrentDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay), dataDrinkingOfTheDayViewItem.amountDrinkOfTheDay < stopNorm {
//                    print("222")
//                    drinkWater(lastNameDrink: lastNameDrink, lastAmountDrink: lastAmountDrink, unit: unit, amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking)
//                } else if dataDrinkingOfTheDay.last!.amountDrinkOfTheDay >= stopNorm {
//                    print("333")
//                    isStopNorm = true
//                    isDrinkedPressed = false
//                }
            }
        case .cancel:
            cancelDrinkWater(amountDrinkOfTheDay: amountDrinkOfTheDay, percentDrinking: percentDrinking, lastNameDrinkProfile: lastNameDrinkProfile, lastAmountDrinkProfile: lastAmountDrinkProfile)
        }
    }
}

#Preview {
    MainView()
}
