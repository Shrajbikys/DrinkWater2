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
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @State private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State var profileViewModel = ProfileViewModel()
    @State var dataDrinkingViewModel = DataDrinkingViewModel()
    @State var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var networkMonitor = NetworkMonitor()
    
    @Binding var isShowingModal: Bool
    @State private var selectedNumber: Int = 250
    @State private var selectedDrink: String = ""
    @State private var isImageDisabled: Bool = true
    @State private var isPremium: Bool = false
    @State private var isPressedImpact: Bool = false
    @State private var normDrink: Double = 2000
    @State private var unit: Int = 0
    
    @State private var imageDrink: [String] = Constants.Back.Drink.imageDrink
    @State private var imageDrinkPremium: [String] = Constants.Back.Drink.imageDrinkPremium
    @State private var nameDrink: [String] = Constants.Back.Drink.nameDrink
    private let nameDrinkPremium: [String] = Constants.Back.Drink.nameDrinkPremium
    @State private var localizedNameDrink: [LocalizedStringKey] = Constants.Back.Drink.localizedNameDrink
    @State private var localizedNameDrinkPremium: [LocalizedStringKey] = Constants.Back.Drink.localizedNameDrinkPremium
    @State private var selectedImages: [String] = Constants.Back.Drink.imageDrinkPremium
    private let hydration: [String: Double] = Constants.Back.Drink.hydration
    
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(nameDrink.indices, id: \.self) { index in
                                Button(action: {
                                    selectedImages = isPremium ? imageDrinkPremium : imageDrink
                                    selectedImages[index] = "\(nameDrink[index])SD" == "\(nameDrink[index])SD" ? "\(nameDrink[index])HighlightedSD" : "\(nameDrink[index])SD"
                                    selectedDrink = nameDrink[index]
                                    isImageDisabled = false
                                }) {
                                    VStack(spacing: 10) {
                                        Image(selectedImages[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 70)
                                        Text(localizedNameDrink[index])
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
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
                        .frame(height: 100)
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
                
                isPremium = purchaseManager.hasPremium
                if isPremium {
                    nameDrink = nameDrinkPremium
                    localizedNameDrink = localizedNameDrinkPremium
                }
                selectedImages = imageDrinkPremium
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
    
    private func drinkWater(amountDrink: Int) {
        let now = Date()
        DispatchQueue.main.async {
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: amountDrink)
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: amountDrink, dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(Double(amountDrink) * (hydration[selectedDrink] ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (Double(amountDrink) * (hydration[selectedDrink] ?? 1.0) / normDrink * 100))
            
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
                let amountOfTheHealthKit = Double(amountDrink) * (hydration[selectedDrink] ?? 1.0)
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
    CustomAmountView(isShowingModal: .constant(false))
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}
