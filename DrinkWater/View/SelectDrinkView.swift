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
    
    @Binding var isShowingModal: Bool
    @State private var isImageToggled: Bool = true
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State var profileViewModel = ProfileViewModel()
    @State var dataDrinkingViewModel = DataDrinkingViewModel()
    @State var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var buttonStates: [Bool] = Array(repeating: false, count: 12)
    @State private var lastSelectedIndex: Int? = nil
    
    @State private var nameDrink: [String] = Constants.Back.Drink.nameDrink
    @State private var nameDrinkPremium: [String] = Constants.Back.Drink.nameDrinkPremium
    @State private var localizedNameDrink: [LocalizedStringKey] = Constants.Back.Drink.localizedNameDrink
    @State private var localizedNameDrinkPremium: [LocalizedStringKey] = Constants.Back.Drink.localizedNameDrinkPremium
    private let nameButtonCustomAmountMl: [Double] = [250, 300, 350, 500]
    private let nameButtonCustomAmountOz: [Double] = [8, 10, 11, 16]
    private let hydration: [String: Double] = Constants.Back.Drink.hydration
    @State private var normDrink: Double = 2000
    @State private var unit: Int = 0
    
    @State private var selectedDrink: String = ""
    @State private var selectedDrinkFirst: Bool = true
    @State private var isPremium: Bool = false
    @State private var isPressedImpact: Bool = false
    
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 30.0)
                            .frame(width: 370, height: 75)
                            .foregroundStyle(backgroundSelectAmountCircleColor)
                        HStack(spacing: 12) {
                            ForEach(0...4, id: \.self) { index in
                                if index < 4 {
                                    Button(action: {
                                        drinkWater(index: index)
                                        isPressedImpact.toggle()
                                        AppMetrica.reportEvent(name: "SelectDrinkView", parameters: ["Press button": "DrinkWater"])
                                        dismiss()
                                    }, label: {
                                        ZStack(alignment: .center) {
                                            Image("BlankAmount")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                            Text("\(profile[0].unit == 0 ? nameButtonCustomAmountMl[index].toStringMilli : nameButtonCustomAmountOz[index].toStringOunces)")
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                        }
                                    })
                                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                                } else {
                                    NavigationLink {
                                        CustomAmountView(isShowingModal: $isShowingModal)
                                    } label: {
                                        ZStack(alignment: .center) {
                                            Image("BlankAmount")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                            Text("+")
                                                .font(.title)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(0..<nameDrink.count, id: \.self) { index in
                                if index % 3 == 0 {
                                    HStack(spacing: 25) {
                                        ForEach(index..<min(index + 3, nameDrink.count), id: \.self) { innerIndex in
                                            VStack {
                                                Button(action: {
                                                    selectedDrinkFirst = false
                                                    selectedDrink = nameDrink[innerIndex]
                                                    if let lastIndex = lastSelectedIndex {
                                                        buttonStates[lastIndex] = false
                                                    }
                                                    buttonStates[innerIndex].toggle()
                                                    lastSelectedIndex = innerIndex
                                                    AppMetrica.reportEvent(name: "SelectDrinkView", parameters: ["Press button": "SelectDrink"])
                                                }) {
                                                    VStack(spacing: 10) {
                                                        if selectedDrinkFirst && selectedDrink == nameDrink[innerIndex] {
                                                            Image("\(selectedDrink)HighlightedSD")
                                                                .resizable()
                                                                .scaledToFit()
                                                        } else {
                                                            Image(buttonStates[innerIndex] ? "\(nameDrink[innerIndex])HighlightedSD" : "\(nameDrink[innerIndex])SD")
                                                                .resizable()
                                                                .scaledToFit()
                                                        }
                                                        Text(localizedNameDrink[innerIndex])
                                                            .font(.subheadline)
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }.padding(.horizontal, 35)
                                }
                            }
                        }
                    }
                    .onAppear {
                        AppMetrica.reportEvent(name: "OpenView", parameters: ["SelectDrinkView": ""])
                        
                        unit = profile[0].unit
                        selectedDrink = profile[0].lastNameDrink
                        
                        if unit == 0 {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                        } else {
                            normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                        }
                        
                        isPremium = purchaseManager.hasPremium
                        if isPremium {
                            nameDrink = nameDrinkPremium
                            localizedNameDrink = localizedNameDrinkPremium
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
    
    private func drinkWater(index: Int) {
        let now = Date()
        DispatchQueue.main.async {
            let amountDrink = unit == 0 ? nameButtonCustomAmountMl[index] : nameButtonCustomAmountOz[index]
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: Int(amountDrink))
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: Int(amountDrink), dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(amountDrink * (hydration[selectedDrink] ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (amountDrink * (hydration[selectedDrink] ?? 1.0) / normDrink * 100))
            
            let percentDrinkNew = (dataDrinkingOfTheDay.last?.percentDrinking ?? 0).rounded(.toNearestOrAwayFromZero)
            let amountDrinkingOfTheDay = dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.amountDrinkOfTheDay ?? 0
            let lastNameDrink = profile[0].lastNameDrink
            WidgetManager.sendDataToWidget(normDrink, amountDrinkingOfTheDay, percentDrinkNew, lastNameDrink, unit, isPremium)
            
            let dateLastDrink = Date().dateFormatForWidgetAndWatch
            let amountUnit = unit == 0 ? "250" : "8"
            let iPhoneAppContext = ["normDrink": String(Int(normDrink)),
                                    "amountDrink": String(amountDrinkingOfTheDay),
                                    "percentDrink": String(Int(percentDrinkNew)),
                                    "amountUnit": amountUnit,
                                    "unit": unit,
                                    "dateLastDrink": dateLastDrink,
                                    "isPremium": isPremium] as [String: Any]
            PhoneSessionManager.shared.sendAppContextToWatch(iPhoneAppContext)
            PhoneSessionManager.shared.transferCurrentComplicationUserInfo(iPhoneAppContext)
            
            if userDefaultsManager.isAuthorizationHealthKit {
                let amountOfTheHealthKit = amountDrink * (hydration[selectedDrink] ?? 1.0)
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
    SelectDrinkView(isShowingModal: .constant(false))
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}
