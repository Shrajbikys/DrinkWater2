//
//  HistoryBodyMetricsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 09.10.2024.
//

import SwiftUI
import SwiftData

struct HistoryBodyMetricsView: View {
    @Query(sort: \BodyMetric.date, order: .forward) var bodyMetric: [BodyMetric]
    
    @State private var selectedDate: Date = Date()
    @State var unit: Int
    @State private var isShowBodyMetricsSheet = false
    @State private var isShowLastBodyMetricsSheet = false
    @State private var isPressedImpact = false
    
    @State private var refreshView = false
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                HStack {
                    Text("История измерений")
                        .font(Constants.Design.Fonts.BodyTitle2Font)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding([.top, .leading])
                YearMonthPickerView(selectedDate: $selectedDate)
                HStack(spacing: 10) {
                    Button {
                        isPressedImpact.toggle()
                        isShowLastBodyMetricsSheet = true
                    } label: {
                        VStack(alignment: .center) {
                            Text("Последняя запись")
                            Text((!bodyMetric.isEmpty ? bodyMetric.last!.date : Date()).formatDayMonthYear)
                        }
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .frame(minWidth: 140, minHeight: 50)
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowLastBodyMetricsSheet) {
                        LastBodyMetricsView(date: !bodyMetric.isEmpty ? bodyMetric.last!.date : Date(),
                                            unit: unit,
                                            chestSize: !bodyMetric.isEmpty ? bodyMetric.last!.chestSize : 0.0,
                                            waistSize: !bodyMetric.isEmpty ? bodyMetric.last!.waistSize : 0.0,
                                            hipSize: !bodyMetric.isEmpty ? bodyMetric.last!.hipSize : 0.0
                        )
                        .presentationDetents([.fraction(0.3)])
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.0))
                            .shadow(color: .white, radius: 2, x: 2, y: 2)
                    }
                    Button {
                        isPressedImpact.toggle()
                        isShowBodyMetricsSheet = true
                    } label: {
                        VStack(alignment: .center) {
                            Text("Добавить новый")
                            Text("замер")
                        }
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .frame(minWidth: 140, minHeight: 50)
                    .sensoryFeedback(.impact, trigger: isPressedImpact)
                    .sheet(isPresented: $isShowBodyMetricsSheet) {
                        ReadingsBodyMetricsView(unit: unit,
                                                chestSize: !bodyMetric.isEmpty ? String(bodyMetric.last!.chestSize) : "0.0",
                                                waistSize: !bodyMetric.isEmpty ? String(bodyMetric.last!.waistSize) : "0.0",
                                                hipSize: !bodyMetric.isEmpty ? String(bodyMetric.last!.hipSize) : "0.0",
                                                refreshView: $refreshView
                        )
                        .presentationDetents([.fraction(0.3)])
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.0))
                            .shadow(color: .white, radius: 2, x: 2, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                if let _ = bodyMetric.first(where: { $0.date.monthYear().compareDate(date: selectedDate.monthYear()) }) {
                    ScrollView {
                        ForEach(bodyMetric) { item in
                            if item.date.monthYear() == selectedDate.monthYear() {
                                HistoryBodyMetricsItemView(date: item.date, unit: unit, chestSize: item.chestSize, waistSize: item.waistSize, hipSize: item.hipSize, differenceChestSize: item.differenceChestSize, differenceWaistSize: item.differenceWaistSize, differenceHipSize: item.differenceHipSize)
                            }
                        }
                    }
                    .id(refreshView)
                } else {
                    ContentUnavailableView("Упс! Пока здесь ничего нет...", systemImage: "vial.viewfinder")
                }
            }
        }
    }
}

#Preview {
    HistoryBodyMetricsView(unit: 0)
        .modelContainer(PreviewContainer.previewContainer)
}
