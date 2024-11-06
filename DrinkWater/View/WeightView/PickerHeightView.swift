//
//  PickerHeightView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.11.2024.
//

import SwiftUI

struct PickerHeightView: View {
    @Environment(\.dismiss) private var dismiss
    @State var profile: [Profile]
    @Binding var selectedValueCm: Int
    @Binding var bmiValue: Double
    @State var selectedValueFt: String = "5'6\""
    private let locale: Locale = .current
    @State private var heightInCm: Double = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Button("Отмена") {
                    dismiss()
                }
                .font(Constants.Design.Fonts.BodyMediumFont)
                Spacer()
                Text("Выберите рост")
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .bold()
                Spacer()
                Button("Сохранить") {
                    DispatchQueue.main.async {
                        profile[0].heightCm = heightInCm
                        bmiValue = calculateBMI(weightKg: profile[0].weightKg, heightCm: heightInCm)
                    }
                    dismiss()
                }
                .font(Constants.Design.Fonts.BodyMediumFont)
                .bold()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            if locale.measurementSystem == .metric {
                Picker("", selection: $selectedValueCm) {
                    ForEach(80...270, id: \.self) { number in
                        Text("\(number) см").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: selectedValueCm) { _, newValue in
                    heightInCm = Double(newValue)
                }
            } else {
                Picker("", selection: $selectedValueFt) {
                    let heightInFeetAndInches = generateHeightOptions()
                    ForEach(heightInFeetAndInches, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: selectedValueFt, { _, _ in
                    updateHeightInCm()
                })
            }
        }
        .onAppear {
            selectedValueFt = convertCentimetersToFeetAndInches(centimeters: Double(selectedValueCm))
        }
    }
}

#Preview {
    PickerHeightView(profile: [Profile(gender: .man, weightKg: 55, heightCm: 170.0, unit: 0, autoNormMl: 1900, customNormMl: 1900, weightPounds: 121, autoNormOz: 67, customNormOz: 67, autoCalc: true, lastAmountDrink: 250, lastNameDrink: "Water")], selectedValueCm: .constant(180), bmiValue: .constant(0.0))
}

extension PickerHeightView {
    func convertCentimetersToFeetAndInches(centimeters: Double) -> String {
        let totalInches = centimeters / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\""
    }
    
    private func updateHeightInCm() {
        let components = selectedValueFt.split { $0 == "'" || $0 == "\"" }
        
        if let feet = components.first, let inches = components.last,
           let feetValue = Int(feet), let inchesValue = Int(inches) {
            let totalInches = Double(feetValue * 12 + inchesValue)
            heightInCm = totalInches * 2.54
        }
    }
    
    func generateHeightOptions() -> [String] {
        var heightOptions = [String]()
        for feet in 2...8 {
            for inches in 0...11 {
                if feet == 2 && inches < 7 {
                    continue
                }
                heightOptions.append("\(feet)'\(inches)\"")
            }
        }
        return heightOptions
    }
    
    private func calculateBMI(weightKg: Double, heightCm: Double) -> Double {
        let heightMeters = heightCm / 100 // перевод роста из сантиметров в метры
        let bmi = weightKg / (heightMeters * heightMeters)
        return bmi
    }
}
