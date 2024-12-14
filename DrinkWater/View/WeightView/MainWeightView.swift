//
//  MainWeightView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 07.10.2024.
//

import SwiftUI
import SwiftData
import Charts
import AppMetricaCore

struct MainWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Query var profile: [Profile]
    @Query(sort: \DataWeight.date, order: .forward) var dataWeight: [DataWeight]
    
    private let userDefaultsManager = UserDefaultsManager.shared
    @State var unit: Int
    
    @State private var networkMonitor = NetworkMonitor()
    
    @State private var isShowWeightSheet = false
    @State private var isShowGoalSheet = false
    @State private var isShowBMISheet = false
    @State private var isShowDataWeightSheet = false
    @State private var isShowDataMetricsSheet = false
    @State private var isDrinkedPressed = false
    @State private var isPressedImpact = false
    @State private var isShadowVisible = false
    
    private let colorFontGoal: Color = Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1))
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    private let backgroundBarMarkColorEmpty: Color = Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)).opacity(0.1)
    private var backgroundBarMarkColor: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)).opacity(0.8), Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)).opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    }
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                Text("\(Date().formatted(.dateTime))")
                    .foregroundStyle(.white).opacity(0.6)
                Text("\(unit == 0 ? (dataWeight.last?.weight ?? 0).toStringKg : (dataWeight.last?.weight ?? 0).toStringPounds)")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                Text(calculateDifferenseValue())
                    .font(.system(size: 40).bold())
                    .foregroundStyle(colorFontGoal)
                Text("Последняя запись \((dataWeight.last?.date ?? Date()).formatted(.dateTime))")
                    .font(.system(.caption))
                    .foregroundStyle(.white).opacity(0.6)
                    .padding(.top, -20)
                Chart {
                    let last14DaysDates = Date().last14DaysDates()
                    ForEach(0..<last14DaysDates.count, id: \.self) { index in
                        let calendar = Calendar.current
                        let last14 = dataWeight.suffix(14)
                        let day = String(calendar.component(.day, from: last14DaysDates[index]))
                        if let data = last14.first(where: { $0.date.compareDate(date: last14DaysDates[index]) }) {
                            BarMark(x: .value("MonthDay", day),
                                    y: .value("WeightValue", data.weight)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .foregroundStyle(backgroundBarMarkColor)
                        } else {
                            BarMark(x: .value("MonthDay", day),
                                    y: .value("WeightValue", dataWeight.last?.goal ?? 0)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .foregroundStyle(backgroundBarMarkColorEmpty)
                        }
                    }
                    RuleMark(y: .value("Goal", dataWeight.last?.goal ?? 0))
                        .lineStyle(.init(lineWidth: 1.0, dash: [5]))
                        .foregroundStyle(colorFontGoal)
                        .annotation(alignment: .leading) {
                            Text("\(unit == 0 ? (dataWeight.last?.goal ?? 0).toStringKg : (dataWeight.last?.goal ?? 0).toStringPounds)")
                                .foregroundStyle(colorFontGoal)
                                .font(.caption)
                                .padding(.leading, 5)
                        }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                    }
                }
                HStack {
                    Button {
                        isPressedImpact.toggle()
                        isShowBMISheet = true
                    } label: {
                        Text("ИМТ: \(String(format: "%.1f", calculateBMI(weightKg: profile[0].weightKg, heightCm: profile[0].heightCm)))")
                    }
                    .frame(width: 120, height: 30)
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.0))
                            .frame(width: 120, height: 30)
                    }
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowBMISheet) {
                        BodyMassIndexView()
                            .presentationDetents([.large])
                    }
                    Spacer()
                    Button {
                        isPressedImpact.toggle()
                        isShowGoalSheet = true
                    } label: {
                        Text("Цель: \(unit == 0 ? (dataWeight.last?.goal ?? 0).toStringKg : (dataWeight.last?.goal ?? 0).toStringPounds)")
                    }
                    .frame(width: 120, height: 30)
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.0))
                            .frame(width: 120, height: 30)
                    }
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowGoalSheet) {
                        ReadingsGoalView(dataWeight: dataWeight, pressedButton: "Goal", isShowKeyboardView: $isShowGoalSheet)
                            .presentationDetents([.fraction(0.85)])
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .padding(.horizontal)
                HStack {
                    Button {
                        isPressedImpact.toggle()
                        isShowDataMetricsSheet = true
                    } label: {
                        Image(systemName: "figure.mixed.cardio.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                            .fontWeight(.thin)
                    }
                    .padding(.horizontal, 40)
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowDataMetricsSheet) {
                        HistoryBodyMetricsView(unit: unit)
                            .presentationDetents([.large])
                    }
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 85, height: 85)
                        .background(backgroundViewColor)
                        .clipShape(Circle())
                        .shadow(color: .white.opacity(isShadowVisible ? 0.6 : 0.4), radius: 10, x: 0, y: 0)
                        .padding(.bottom, 20)
                        .scaleEffect(isDrinkedPressed ? 0.5 : 1.0)
                        .animation(.linear(duration: 0.2), value: isDrinkedPressed)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                isShadowVisible.toggle()
                            }
                        }
                        .onTapGesture {
                            isDrinkedPressed = true
                            isPressedImpact.toggle()
                            DispatchQueue.main.async {
                                isShowWeightSheet = true
                                isDrinkedPressed = false
                            }
                        }
                        .sensoryFeedback(.impact, trigger: isPressedImpact)
                        .sheet(isPresented: $isShowWeightSheet) {
                            ReadingsWeightView(pressedButton: "Weight", isShowKeyboardView: $isShowWeightSheet)
                                .presentationDetents([.fraction(0.85)])
                        }
                    Spacer()
                    Button {
                        isPressedImpact.toggle()
                        isShowDataWeightSheet = true
                    } label: {
                        Image(systemName: "calendar.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                            .fontWeight(.thin)
                    }
                    .padding(.horizontal, 40)
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowDataWeightSheet) {
                        HistoryWeightView(unit: unit)
                            .presentationDetents([.large])
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if networkMonitor.isConnected {
                AppMetrica.reportEvent(name: "OpenView", parameters: ["MainWeightView": ""])
            }
            
            let isFirstSignWidth = userDefaultsManager.isFirstSignWidth
            if !isFirstSignWidth {
                userDefaultsManager.isFirstSignWidth = true
            }
        }
    }
}

extension MainWeightView {
    private func calculateBMI(weightKg: Double, heightCm: Double) -> Double {
        let heightMeters = heightCm / 100
        let bmi = weightKg / (heightMeters * heightMeters)
        return bmi
    }
    
    private func calculateDifferenseValue() -> LocalizedStringKey {
        var result: LocalizedStringKey = ""
        if dataWeight.last?.weightGoalType ?? 0 == 0 {
            if !dataWeight.isEmpty && dataWeight.last!.weight <= dataWeight.last!.goal {
                result = "Цель достигнута!"
            } else {
                let weight = unit == 0 ? (dataWeight.last?.weight ?? 0) : (dataWeight.last?.weight ?? 0)
                let goal = unit == 0 ? (dataWeight.last?.goal ?? 0) : (dataWeight.last?.goal ?? 0)
                result = "\(unit == 0 ? (weight - goal).toStringKg : (weight - goal).toStringPounds) до цели"
            }
        } else {
            if !dataWeight.isEmpty && dataWeight.last!.weight >= dataWeight.last!.goal {
                result = "Цель достигнута!"
            } else {
                let weight = unit == 0 ? (dataWeight.last?.weight ?? 0) : (dataWeight.last?.weight ?? 0)
                let goal = unit == 0 ? (dataWeight.last?.goal ?? 0) : (dataWeight.last?.goal ?? 0)
                result = "\(unit == 0 ? (goal - weight).toStringKg : (goal - weight).toStringPounds) до цели"
            }
        }
        return result
    }
}

#Preview {
    MainWeightView(unit: 0)
        .modelContainer(PreviewContainer.previewContainer)
}
