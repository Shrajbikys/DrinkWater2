//
//  NormModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI

struct NormModalView: View {
    @State var profile: [Profile]
    
    var profileViewModel = ProfileViewModel()
    
    @Binding var isNormShowingModal: Bool
    @Binding var selectedNorm: Int
    @Binding var sliderValue: Double
    
    var body: some View {
        VStack {
            Text("Выберите вашу норму:")
                .font(Constants.Design.Fonts.BodyMainFont)
                .padding(.top, 30)
            Picker("Выберите вашу норму:", selection: $selectedNorm) {
                ForEach(Array(stride(
                    from: profile[0].unit == 0 ? 100 : 2,
                    to: profile[0].unit == 0 ? 4100 : 142,
                    by: profile[0].unit == 0 ? 100 : 1
                )), id: \.self) { number in
                    Text("\(number)")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            Button("Сохранить") {
                profileViewModel.updateProfileCustomNormData(profile: profile, customNorm: Double(selectedNorm))
                sliderValue = Double(selectedNorm)
                isNormShowingModal = false
            }
            .font(Constants.Design.Fonts.BodyMainFont)
            .bold()
        }
    }
}

#Preview {
    NormModalView(profile: [Profile(gender: .man, weightKg: 55, heightCm: 170.0, unit: 0, autoNormMl: 1900, customNormMl: 1900, weightPounds: 121, autoNormOz: 67, customNormOz: 67, autoCalc: true, lastAmountDrink: 250, lastNameDrink: "Water")], isNormShowingModal: .constant(false), selectedNorm: .constant(2100), sliderValue: .constant(2100))
        .modelContainer(PreviewContainer.previewContainer)
}
