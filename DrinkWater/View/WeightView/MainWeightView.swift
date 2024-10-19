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
    @Query(sort: \DataWeight.date, order: .forward) var dataWeight: [DataWeight]
    
    private let userDefaultsManager = UserDefaultsManager.shared
    @State var unit: Int
    
    @State private var showWeightSheet = false
    @State private var showGoalSheet = false
    @State private var showDataWeightSheet = false
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    private var backgroundBarMarkColor: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)), Color(#colorLiteral(red: 0.9568627477, green: 0.5766853228, blue: 0.4625490829, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    }
    private var backgroundBarMarkColorEmpty: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.5))]), startPoint: .top, endPoint: .bottom)
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
                .padding(.top, 10)
                .padding(.bottom, 10)
                Text("\(Date().formatted(.dateTime))")
                    .foregroundStyle(.white).opacity(0.6)
                Text("\(unit == 0 ? (dataWeight.last?.weight ?? 0).toStringKg : (dataWeight.last?.weight ?? 0).toStringPounds)")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                if !dataWeight.isEmpty && dataWeight.last!.weight <= dataWeight.last!.goal {
                    Text("Цель достигнута!")
                        .font(.system(size: 40).bold())
                        .foregroundStyle(.yellow)
                } else {
                    let weight = unit == 0 ? (dataWeight.last?.weight ?? 0) : (dataWeight.last?.weight ?? 0)
                    let goal = unit == 0 ? (dataWeight.last?.goal ?? 0) : (dataWeight.last?.goal ?? 0)
                    Text("\(unit == 0 ? (weight - goal).toStringKg : (weight - goal).toStringPounds) до цели")
                        .font(.system(size: 40).bold())
                        .foregroundStyle(.yellow)
                }
                Button("Последняя запись \((dataWeight.last?.date ?? Date()).formatted(.dateTime))") {
                    AppMetrica.reportEvent(name: "MainWeightView", parameters: ["Press button": "HistoryWeightView"])
                    showDataWeightSheet = true
                }
                .font(.system(.caption))
                .buttonStyle(.bordered)
                .padding(.top, -20)
                .shadow(radius: 5)
                .foregroundStyle(.white).opacity(0.6)
                .sheet(isPresented: $showDataWeightSheet) {
                    HistoryWeightView(unit: unit)
                        .presentationDetents([.large])
                }
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
                            .foregroundStyle(backgroundBarMarkColor)
                        } else {
                            BarMark(x: .value("MonthDay", day),
                                    y: .value("WeightValue", dataWeight.first?.weight ?? 0)
                            ).foregroundStyle(backgroundBarMarkColorEmpty)
                        }
                    }
                    RuleMark(y: .value("Goal", dataWeight.last?.goal ?? 0))
                        .lineStyle(.init(lineWidth: 1.0, dash: [5]))
                        .foregroundStyle(.white)
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                    }
                }
                Spacer()
                Button {
                    AppMetrica.reportEvent(name: "MainWeightView", parameters: ["Press button": "ReadingsGoalView"])
                    showGoalSheet = true
                } label: {
                    Text("Цель: \(unit == 0 ? (dataWeight.last?.goal ?? 0).toStringKg : (dataWeight.last?.goal ?? 0).toStringPounds)")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .overlay {
                    Rectangle()
                        .stroke(.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.0))
                        .frame(width: 120, height: 30)
                }
                .sheet(isPresented: $showGoalSheet) {
                    ReadingsGoalView(selectedButton: "Goal")
                        .presentationDetents([.fraction(0.85)])
                }
                .padding(.vertical)
                Button {
                    AppMetrica.reportEvent(name: "MainWeightView", parameters: ["Press button": "ReadingsWeightView"])
                    showWeightSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 85, height: 85)
                        .background(.orange)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $showWeightSheet) {
                    ReadingsWeightView(selectedButton: "Weight")
                        .presentationDetents([.fraction(0.85)])
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let isFirstSignWidth = userDefaultsManager.isFirstSignWidth
            if !isFirstSignWidth {
                userDefaultsManager.isFirstSignWidth = true
            }
        }
    }
}

#Preview {
    MainWeightView(unit: 0)
        .modelContainer(PreviewContainer.previewContainer)
}
