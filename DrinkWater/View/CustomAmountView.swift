//
//  CustomAmountView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 28.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData

struct CustomAmountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State var profileViewModel = ProfileViewModel()
    @State var dataDrinkingViewModel = DataDrinkingViewModel()
    @State var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @Binding var isShowingModal: Bool
    @State private var selectedNumber: Int = 250
    @State private var selectedDrink: String = ""
    @State private var isImageDisabled: Bool = true
    let imageDrink = ["WaterSD", "CoffeeSD", "TeaSD", "MilkSD", "JuiceSD", "SodaSD", "CocoaSD", "SmoothieSD", "YogurtSD", "BeerSD", "NonalcoholicBeerSD", "WineSD"]
    let imageSelectedDrink = ["WaterHighlightedSD", "CoffeeHighlightedSD", "TeaHighlightedSD", "MilkHighlightedSD", "JuiceHighlightedSD", "SodaHighlightedSD", "CocoaHighlightedSD", "SmoothieHighlightedSD", "YogurtHighlightedSD", "BeerHighlightedSD", "NonalcoholicBeerHighlightedSD", "WineHighlightedSD"]
    let nameDrink = ["Water", "Coffee", "Tea", "Milk", "Juice", "Soda", "Cocoa", "Smoothie", "Yogurt", "Beer", "Non alc. beer", "Wine"]
    let valuesMl = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350, 1400, 1450, 1500, 1550, 1600, 1650, 1700, 1750, 1800, 1850, 1900, 1950, 2000]
    @State private var selectedImages: [String] = ["WaterSD", "CoffeeSD", "TeaSD", "MilkSD", "JuiceSD", "SodaSD", "CocoaSD", "SmoothieSD", "YogurtSD", "BeerSD", "NonalcoholicBeerSD", "WineSD"]
    let hydration: [String: Double] = ["Water": 1.0, "Coffee": 0.8, "Tea": 0.9, "Milk": 0.9, "Juice": 0.8, "Soda": 0.9, "Cocoa": 0.7, "Smoothie": 0.3, "Yogurt": 0.5, "Beer": -0.6, "NonalcoholicBeer": 0.6, "Wine": -1.6]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
                    .ignoresSafeArea()
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(imageDrink.indices, id: \.self) { index in
                                Button(action: {
                                    selectedImages = ["WaterSD", "CoffeeSD", "TeaSD", "MilkSD", "JuiceSD", "SodaSD", "CocoaSD", "SmoothieSD", "YogurtSD", "BeerSD", "NonalcoholicBeerSD", "WineSD"]
                                    selectedImages[index] = imageDrink[index] == imageDrink[index] ? imageSelectedDrink[index] : imageDrink[index]
                                    selectedDrink = nameDrink[index]
                                    isImageDisabled = false
                                }) {
                                    VStack(spacing: 10) {
                                        Image(selectedImages[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 70)
                                        Text(nameDrink[index])
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                    }
                    .onAppear {
                        selectedImages = imageDrink
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
                            ForEach(0..<valuesMl.count, id: \.self) { index in
                                Text("\(valuesMl[index])")
                                    .tag(valuesMl[index])
                                    .foregroundStyle(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        Button("Добавить напиток") {
                            drinkWater(selectedNumber: selectedNumber)
                            isShowingModal = false
                        }
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
    
    private func drinkWater(selectedNumber: Int) {
        let now = Date()
        DispatchQueue.main.async {
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: selectedNumber)
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: selectedNumber, dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(Double(selectedNumber) * (hydration[profile[0].lastNameDrink] ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (Double(selectedNumber) * (hydration[profile[0].lastNameDrink] ?? 1.0) / profile[0].autoNormMl * 100))
            
            if userDefaultsManager.isAuthorizationHealthKit {
                let amountOfTheHealthKit = Double(profile[0].lastAmountDrink) * (hydration[profile[0].lastNameDrink] ?? 1.0)
                healthKitManager.saveWaterIntake(amount: amountOfTheHealthKit, date: now, unit: profile[0].unit) { (success, error) in
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
}
