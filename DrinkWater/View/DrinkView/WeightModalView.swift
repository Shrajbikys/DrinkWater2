//
//  WeightModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI

struct WeightModalView: View {
    @State var profile: [Profile]?
    @State var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]?
    
    var profileViewModel = ProfileViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @Binding var isWeightShowingModal: Bool
    @State var selectedWeight: Int
    @State var selectedWeightFractional: Int
    
    @State var unitValue: Int
    
    var body: some View {
        VStack {
            Text("Выберите ваш вес:")
                .font(Constants.Design.Fonts.BodyMainFont)
                .padding(.top, 30)
            HStack {
                Picker("", selection: $selectedWeight) {
                    ForEach(unitValue == 0 ? (20...200).map { $0 } : (44...400).map { $0 }, id: \.self) { number in
                        Text("\(number)").tag(number)
                            .font(Constants.Design.Fonts.BodyMainFont)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .padding(.trailing, -15)
                VStack {
                    Text(unitValue == 0 ? "," : ".")
                        .padding(.top, 10)
                }
                Picker("", selection: $selectedWeightFractional) {
                    ForEach((0...9).map { $0 }, id: \.self) { number in
                        Text("\(number)").tag(number)
                            .font(Constants.Design.Fonts.BodyMainFont)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .padding(.leading, -15)
            }
            Button("Сохранить") {
                if let profile = profile {
                    if !profile.isEmpty {
                        let weight = Double(selectedWeight) + Double(selectedWeightFractional) / 10
                        profileViewModel.updateProfileWeightData(profile: profile, weight: weight)
                        if let dataDrinkingOfTheDay = dataDrinkingOfTheDay {
                            if !dataDrinkingOfTheDay.isEmpty {
                                let autoNorm = unitValue == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                                let percentDrinking = Double(dataDrinkingOfTheDay.last!.amountDrinkOfTheDay) / autoNorm * 100
                                dataDrinkingOfTheDayViewModel.updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, percentDrinking: percentDrinking)
                            }
                        }
                    }
                }
                isWeightShowingModal = false
            }
            .font(Constants.Design.Fonts.BodyMainFont)
            .bold()
        }
    }
}

#Preview {
    WeightModalView(isWeightShowingModal: .constant(false), selectedWeight: 50, selectedWeightFractional: 3, unitValue: 0)
        .modelContainer(PreviewContainer.previewContainer)
}
