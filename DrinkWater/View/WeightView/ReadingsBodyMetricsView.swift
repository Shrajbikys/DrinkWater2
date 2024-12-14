//
//  ReadingsBodyMetricsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 09.12.2024.
//

import SwiftUI
import SwiftData

struct ReadingsBodyMetricsView: View {
    @Query var profile: [Profile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BodyMetric.date, order: .forward) var bodyMetric: [BodyMetric]
    
    @State var unit: Int
    @State var chestSize: String
    @State var waistSize: String
    @State var hipSize: String
    
    @Binding var refreshView: Bool
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundViewColor
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват груди")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        TextField("0", text: $chestSize)
                            .multilineTextAlignment(.center)
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .keyboardType(.decimalPad)
                            .frame(width: 80, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        Text(extractLengthSymbol(from: chestSize))
                            .font(Constants.Design.Fonts.BodyMediumFont)
                    }
                    .foregroundStyle(.white)
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват талии")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        TextField("0", text: $waistSize)
                            .multilineTextAlignment(.center)
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .keyboardType(.decimalPad)
                            .frame(width: 80, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        Text(extractLengthSymbol(from: waistSize))
                            .font(Constants.Design.Fonts.BodyMediumFont)
                    }
                    .foregroundStyle(.white)
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват бёдер")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        TextField("0", text: $hipSize)
                            .multilineTextAlignment(.center)
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .keyboardType(.decimalPad)
                            .frame(width: 80, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        Text(extractLengthSymbol(from: hipSize))
                            .font(Constants.Design.Fonts.BodyMediumFont)
                    }
                    .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .navigationTitle("Введите данные")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "xmark")
                            Text("Отмена")
                        }
                        .font(Constants.Design.Fonts.BodySmallFont)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if !bodyMetric.isEmpty && bodyMetric.last!.date.yearMonthDay == Date().yearMonthDay {
                            bodyMetric.last!.date = Date()
                            bodyMetric.last!.chestSize = normalizedDecimal(chestSize) ?? 0.0
                            bodyMetric.last!.hipSize = normalizedDecimal(hipSize) ?? 0.0
                            bodyMetric.last!.waistSize = normalizedDecimal(waistSize) ?? 0.0

                            if bodyMetric.count > 1 {
                                if bodyMetric.last!.chestSize == 0.0 || bodyMetric[bodyMetric.count - 2].chestSize == 0.0 {
                                    bodyMetric.last!.differenceChestSize = 0.0
                                } else {
                                    bodyMetric.last!.differenceChestSize = bodyMetric.last!.chestSize - bodyMetric[bodyMetric.count - 2].chestSize
                                }
                                
                                if bodyMetric.last!.hipSize == 0.0 || bodyMetric[bodyMetric.count - 2].hipSize == 0.0 {
                                    bodyMetric.last!.differenceHipSize = 0.0
                                } else {
                                    bodyMetric.last!.differenceHipSize = bodyMetric.last!.hipSize - bodyMetric[bodyMetric.count - 2].hipSize
                                }
                                
                                if bodyMetric.last!.waistSize == 0.0 || bodyMetric[bodyMetric.count - 2].waistSize == 0.0 {
                                    bodyMetric.last!.differenceWaistSize = 0.0
                                } else {
                                    bodyMetric.last!.differenceWaistSize = bodyMetric.last!.waistSize - bodyMetric[bodyMetric.count - 2].waistSize
                                }
                            }
                        } else {
                            let bodyMetricItem = BodyMetric()
                            bodyMetricItem.date = Date()
                            bodyMetricItem.chestSize = normalizedDecimal(chestSize) ?? 0.0
                            bodyMetricItem.hipSize = normalizedDecimal(hipSize) ?? 0.0
                            bodyMetricItem.waistSize = normalizedDecimal(waistSize) ?? 0.0
                            
                            if bodyMetric.count > 0 {
                                if bodyMetric.last!.chestSize == 0.0 || normalizedDecimal(chestSize) == 0.0 {
                                    bodyMetricItem.differenceChestSize = 0.0
                                } else {
                                    bodyMetricItem.differenceChestSize = (normalizedDecimal(chestSize) ?? 0.0) - bodyMetric.last!.chestSize
                                }
                                
                                if bodyMetric.last!.hipSize == 0.0 || normalizedDecimal(hipSize) == 0.0 {
                                    bodyMetricItem.differenceHipSize = 0.0
                                } else {
                                    bodyMetricItem.differenceHipSize = (normalizedDecimal(hipSize) ?? 0.0) - bodyMetric.last!.hipSize
                                }
                                
                                if bodyMetric.last!.waistSize == 0.0 || normalizedDecimal(waistSize) == 0.0 {
                                    bodyMetricItem.differenceWaistSize = 0.0
                                } else {
                                    bodyMetricItem.differenceWaistSize = (normalizedDecimal(waistSize) ?? 0.0) - bodyMetric.last!.waistSize
                                }
                            } else {
                                bodyMetricItem.differenceChestSize = 0.0
                                bodyMetricItem.differenceHipSize = 0.0
                                bodyMetricItem.differenceWaistSize = 0.0
                            }
                            
                            modelContext.insert(bodyMetricItem)
                        }
                        refreshView.toggle()
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark")
                            Text("Сохранить")
                        }
                        .font(Constants.Design.Fonts.BodySmallFont)
                    }
                }
            }
        }
    }
}

extension ReadingsBodyMetricsView {
    private func normalizedDecimal(_ value: String) -> Double? {
        let correctedValue = value.replacingOccurrences(of: ",", with: ".")
        return Double(correctedValue)
    }
    
    private func extractLengthSymbol(from value: String) -> String {
        guard let doubleValue = normalizedDecimal(value) else { return "" }
        let measurement = Measurement(value: doubleValue, unit: UnitLength.centimeters)
        
        let formattedValue = measurement.formatted(.measurement(width: .abbreviated, usage: .asProvided))
        
        // Извлекаем символ единицы измерения
        let symbol = formattedValue.components(separatedBy: .whitespaces).last ?? ""
        return symbol
    }
}

#Preview {
    ReadingsBodyMetricsView(unit: 0, chestSize: "90.0", waistSize: "60.0", hipSize: "90.0", refreshView: .constant(true))
        .modelContainer(PreviewContainer.previewContainer)
}
