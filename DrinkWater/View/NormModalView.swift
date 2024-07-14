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
            Text("Выберите ваш вес:")
                .font(.headline)
                .padding(.top, 30)
            Picker("Выберите вашу норму:", selection: $selectedNorm) {
                ForEach(Array(stride(
                    from: profile[0].unit == 0 ? 100 : 0,
                    to: profile[0].unit == 0 ? 4100 : 142,
                    by: profile[0].unit == 0 ? 100 : 2
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
            .bold()
        }
    }
}

//#Preview {
//    NormModalView()
//}
