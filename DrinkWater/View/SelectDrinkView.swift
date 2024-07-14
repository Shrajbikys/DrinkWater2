//
//  SelectDrinkView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData

struct SelectDrinkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
    @State private var nameDrink: Array<String> = ["Water", "Coffee", "Tea", "Milk", "Juice", "Soda", "Cocoa", "Smoothie", "Yogurt", "Beer", "NonalcoholicBeer", "Wine"]
    let nameButtonCustomAmount: [Double] = [250, 300, 350, 500]
    @State private var selectedImages: [String] = ["WaterSD", "CoffeeSD", "TeaSD", "MilkSD", "JuiceSD", "SodaSD", "CocoaSD", "SmoothieSD", "YogurtSD", "BeerSD", "NonalcoholicBeerSD", "WineSD"]
    private let hydration: [String: Double] = ["Water": 1.0, "Coffee": 0.8, "Tea": 0.9, "Milk": 0.9, "Juice": 0.8, "Soda": 0.9, "Cocoa": 0.7, "Smoothie": 0.3, "Yogurt": 0.5, "Beer": -0.6, "NonalcoholicBeer": 0.6, "Wine": -1.6]
    
    @State private var selectedDrink: String = ""
    @State private var selectedDrinkFirst: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
                    .ignoresSafeArea()
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white)
                    ZStack {
                        RoundedRectangle(cornerRadius: 30.0)
                            .frame(width: 370, height: 75)
                            .foregroundStyle(Color(#colorLiteral(red: 0.5921568627, green: 0.7921568627, blue: 0.9882352941, alpha: 0.35)))
                        HStack(spacing: 12) {
                            ForEach(0...4, id: \.self) { index in
                                if index < 4 {
                                    Button(action: {
                                        drinkWater(index: index)
                                        dismiss()
                                    }, label: {
                                        ZStack(alignment: .center) {
                                            Image("BlankAmount")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                            Text("\(Int(nameButtonCustomAmount[index])) мл")
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                        }
                                    })
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
                                                        Text(nameDrink[innerIndex])
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
                        selectedDrink = profile[0].lastNameDrink
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
            profileViewModel.updateProfileDrinkData(profile: profile, lastNameDrink: selectedDrink, lastAmountDrink: Int(nameButtonCustomAmount[index]))
            dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: selectedDrink, amountDrink: Int(nameButtonCustomAmount[index]), dateDrink: now)
            dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: Int(nameButtonCustomAmount[index] * (hydration[profile[0].lastNameDrink] ?? 1.0)), dateDrinkOfTheDay: now, percentDrinking: (nameButtonCustomAmount[index] * (hydration[profile[0].lastNameDrink] ?? 1.0) / profile[0].autoNormMl * 100))
            
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
    SelectDrinkView(isShowingModal: .constant(false))
}
