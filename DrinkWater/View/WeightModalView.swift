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
    @Binding var selectedWeight: Double
    
    @State var unitValue: Int
    
    var body: some View {
        VStack {
            Text("Выберите ваш вес:")
                .font(Constants.Design.Fonts.BodyMainFont)
                .padding(.top, 30)
            Picker("Выберите ваш вес:", selection: $selectedWeight) {
                ForEach(unitValue == 0 ? (20...200).map { Double($0) } : (44...400).map { Double($0) }, id: \.self) { number in
                    Text("\(Int(number))").tag(number)
                }
            }.pickerStyle(.wheel)
            Button("Сохранить") {
                if let profile = profile {
                    if !profile.isEmpty {
                        profileViewModel.updateProfileWeightData(profile: profile, weight: selectedWeight)
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
    WeightModalView(isWeightShowingModal: .constant(false), selectedWeight: .constant(50), unitValue: 0)
        .modelContainer(PreviewContainer.previewContainer)
}
