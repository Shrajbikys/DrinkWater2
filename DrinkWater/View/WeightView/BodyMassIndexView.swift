//
//  BodyMassIndexView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.11.2024.
//

import SwiftUI
import SwiftData

struct BodyMassIndexView: View {
    @Query var profile: [Profile]
    @State private var isPressedImpact = false
    
    @State private var bmiValue: Double = 0.0
    private var minValue: Double = 16.0
    private var maxValue: Double = 30.0
    
    @State private var isShowPickerHeight = false
    @State private var selectedValue = 170
    
    private var normalizedBMI: Double {
        let clampedBMI = min(max(bmiValue, minValue), maxValue)
        return (clampedBMI - minValue) / (maxValue - minValue)
    }
    
    private let bmiColorGradient = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: .brown, location: 0.0),
            .init(color: .blue, location: 0.1),
            .init(color: .green, location: 0.3),
            .init(color: .yellow, location: 0.9),
            .init(color: .red, location: 1.0)
        ]),
        center: .center,
        startAngle: .degrees(90),
        endAngle: .degrees(360)
    )
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    private let colorFontGoal: Color = Color(#colorLiteral(red: 0.9254901961, green: 0.7647058824, blue: 0.3176470588, alpha: 1))
    
    private let descriptionBMI: [LocalizedStringKey] = ["Cильный дефицит массы тела", "Дефицит массы тела", "Нормальный вес", "Лишний вес", "Ожирение"]
    private let valueBMI: [String] = ["< 17.0", "17.0 - 18.4", "18.5 - 24.9", "25.0 - 29.9", "> 29.9"]
    private let colorBMI: [Color] = [.brown, .blue, .green, .yellow, .red]
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Text("Индекс массы тела")
                            .font(Constants.Design.Fonts.BodyTitle2Font)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    HStack(spacing: spacingBetweenElements(for: geometry.size.width)) {
                        ZStack {
                            Circle()
                                .trim(from: 0.28, to: 1)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(39))
                            Circle()
                                .trim(from: 0.28, to: 1)
                                .stroke(bmiColorGradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(39))
                            Circle()
                                .fill(.white)
                                .frame(width: 15, height: 15)
                                .offset(y: -100)
                                .rotationEffect(.degrees(230 + 260 * normalizedBMI))
                            VStack {
                                Text("ИМТ")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.white)
                                Text(String(format: "%.1f", bmiValue))
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(bmiColor(for: bmiValue))
                            }
                        }
                        VStack(spacing: 40) {
                            VStack {
                                Text("Вес:")
                                    .foregroundStyle(.white)
                                Text("\(profile[0].unit == 0 ? (profile[0].weightKg).toStringKg : (profile[0].weightPounds).toStringPounds)")
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(.white, style: StrokeStyle(lineWidth: 1.0))
                                    .frame(width: 100, height: 60)
                            }
                            Button {
                                isPressedImpact.toggle()
                                isShowPickerHeight = true
                            } label: {
                                VStack {
                                    Text("Рост:")
                                        .foregroundStyle(.white)
                                    Text("\(formatHeight(forHeightInCm: profile[0].heightCm)) см")
                                        .foregroundStyle(.white)
                                        .bold()
                                }
                            }
                            .frame(width: 100, height: 60)
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(.white, style: StrokeStyle(lineWidth: 1.0))
                                    .frame(width: 100, height: 60)
                            }
                            .sensoryFeedback(.impact, trigger: isPressedImpact)
                            .sheet(isPresented: $isShowPickerHeight) {
                                PickerHeightView(profile: profile, selectedValueCm: $selectedValue, bmiValue: $bmiValue)
                                    .presentationDetents([.fraction(0.3)])
                            }
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Индекс массы тела (ИМТ) — это показатель, который помогает оценить, соответствует ли вес человека его росту.")
                            Text("ИМТ позволяет определить, находится ли вес в пределах нормы, или есть риск недостатка, избытка веса или ожирения.")
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.bottom)
                    HStack {
                        Text("Основные показатели")
                            .font(Constants.Design.Fonts.BodyMainFont)
                            .foregroundStyle(Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)))
                            .bold()
                    }
                    ForEach(0..<descriptionBMI.count, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(colorBMI[index])
                                .frame(width: 15, height: 15)
                            Text(descriptionBMI[index])
                                .bold(colorBMI[index] == bmiColor(for: bmiValue))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(valueBMI[index])
                                .bold(colorBMI[index] == bmiColor(for: bmiValue))
                                .foregroundStyle(colorBMI[index] == bmiColor(for: bmiValue) ? Color(#colorLiteral(red: 1, green: 0.8323286176, blue: 0.4732042551, alpha: 1)) : .white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(style: StrokeStyle(lineWidth: colorBMI[index] == bmiColor(for: bmiValue) ? 2 : 1, dash: [10, colorBMI[index] == bmiColor(for: bmiValue) ? 5 : 5]))
                                .foregroundStyle(colorBMI[index] == bmiColor(for: bmiValue) ? Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)) : .white)
                                .opacity(0.5)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .onAppear {
            selectedValue = Int(profile[0].heightCm)
            bmiValue = calculateBMI(weightKg: profile[0].weightKg, heightCm: profile[0].heightCm)
        }
    }
}

#Preview {
    BodyMassIndexView()
        .modelContainer(PreviewContainer.previewContainer)
}

extension BodyMassIndexView {
    private func spacingBetweenElements(for width: CGFloat) -> CGFloat {
        return width > 402 ? 45 : 20
    }
    
    private func formatHeight(forHeightInCm heightInCm: Double, locale: Locale = .current) -> String {
        if locale.measurementSystem == .metric {
            return "\(Int(heightInCm))"
        } else {
            let heightInInches = heightInCm / 2.54
            let feet = Int(heightInInches / 12)
            let inches = Int(heightInInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
        }
    }
    
    private func calculateBMI(weightKg: Double, heightCm: Double) -> Double {
        let heightMeters = heightCm / 100
        let bmi = weightKg / (heightMeters * heightMeters)
        return bmi
    }
    
    private func bmiColor(for bmi: Double) -> Color {
        switch bmi {
        case ..<17.0:
            return .brown
        case 17.0..<18.5:
            return .blue
        case 18.5..<25:
            return .green
        case 25..<30:
            return .yellow
        case 30..<40:
            return .red
        default:
            return .green
        }
    }
}
