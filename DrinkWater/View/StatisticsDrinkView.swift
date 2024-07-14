//
//  StatisticsDrinkView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 29.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsDrinkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var dataDrinkingViewModel = DataDrinkingViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var selectedSegment: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var isEmpty: Bool = true
    
    let hydration: [String: Double] = ["Water": 1.0, "Coffee": 0.8, "Tea": 0.9, "Milk": 0.9, "Juice": 0.8, "Soda": 0.9, "Cocoa": 0.7, "Smoothie": 0.3, "Yogurt": 0.5, "Beer": -0.6, "NonalcoholicBeer": 0.6, "Wine": -1.6]
    
    let segments: Array<String> = ["Неделя", "Месяц"]
    
    struct ToyShape: Identifiable {
        var type: String
        var count: Double
        var id = UUID()
    }
    
    @State var selectedWeek: [Date] = Date().thisWeek
    @State var selectedMonth: [Date] = [Date().thisMonthStart, Date().thisMonthEnd]
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
                    .ignoresSafeArea()
                VStack {
                    Picker("Days", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    HStack(alignment: .center) {
                        Button(action: {
                            if selectedSegment == 0 {
                                selectedWeek = selectedWeek.first!.lastWeek
                            } else {
                                selectedMonth = getAllDatesInCurrentMonth(date: selectedMonth.first!.lastMonthStart)
                            }
                        }, label: {
                            Image(systemName: "chevron.left.circle")
                                .font(.title2)
                                .foregroundStyle(.white)
                        })
                        Text(selectedSegment == 0 ? "\(selectedWeek.first!.formatForPeriodDates) - \(selectedWeek.last!.formatForPeriodDates)" : "\(selectedMonth.first!.formatForPeriodDates) - \(selectedMonth.last!.formatForPeriodDates)")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        Button(action: {
                            if selectedSegment == 0 {
                                selectedWeek = selectedWeek.first!.nextWeek
                            } else {
                                selectedMonth = getAllDatesInCurrentMonth(date: selectedMonth.first!.nextMonthStart)
                            }
                        }, label: {
                            Image(systemName: "chevron.right.circle")
                                .font(.title2)
                                .foregroundStyle(.white)
                        })
                    }
                    .padding(.vertical)
                    if selectedSegment == 0 {
                        Chart {
                            ForEach(selectedWeek, id: \.self) { itemDate in
                                ForEach(dataDrinkingOfTheDay) { item in
                                    if itemDate.compareDate(date: item.dateDrinkOfTheDay) {
                                        BarMark(
                                            x: .value("Week Day", itemDate.nameDay),
                                            y: .value("Drunk", item.amountDrinkOfTheDay)
                                        )
                                        .annotation(position: .top, alignment: .center) {
                                            Text("\(Int(item.amountDrinkOfTheDay))")
                                                .font(.system(size: 8))
                                                .foregroundStyle(Color.secondary)
                                        }
                                    } else {
                                        BarMark(
                                            x: .value("Week Day", itemDate.nameDay),
                                            y: .value("Drunk", 0)
                                        )
                                    }
                                }
                            }
                        }
                        .chartYScale(domain: 0...4000)
                        .chartYAxis(content: {
                            AxisMarks(position: .leading)
                        })
                        .foregroundStyle(Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)))
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    } else {
                        Chart {
                            ForEach(selectedMonth, id: \.self) { itemDate in
                                ForEach(dataDrinkingOfTheDay) { item in
                                    if itemDate.compareDate(date: item.dateDrinkOfTheDay) {
                                        BarMark(
                                            x: .value("Week Day", itemDate.dayShort),
                                            y: .value("Drunk", item.amountDrinkOfTheDay)
                                        )
                                    } else {
                                        BarMark(
                                            x: .value("Week Day", itemDate.dayShort),
                                            y: .value("Drunk", 0)
                                        )
                                    }
                                }
                            }
                        }
                        .chartScrollableAxes(.horizontal)
                        .chartYScale(domain: 0...4000)
                        .chartYAxis(content: {
                            AxisMarks(position: .leading)
                        })
                        .foregroundStyle(Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1)))
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    Text("Статистика за день")
                        .font(Constants.Design.AppFont.BodyLargeFont)
                        .foregroundStyle(.white)
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<dataDrinkingOfTheDay.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIndex = index
                                        selectedDate = dataDrinkingOfTheDay[index].dateDrinkOfTheDay
                                    }, label: {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIndex == index ? Color(#colorLiteral(red: 0.3114904165, green: 0.5568692684, blue: 0.7960240245, alpha: 1)) : .clear)
                                            VStack {
                                                Text(dataDrinkingOfTheDay[index].dateDrinkOfTheDay.dayShort)
                                                Text(dataDrinkingOfTheDay[index].dateDrinkOfTheDay.abbreviatedMonth)
                                            }
                                            .foregroundStyle(.white)
                                            .font(.caption)
                                        }
                                    })
                                    .id(index)
                                    .frame(width: 57, height: 57)
                                    .onAppear {
                                        if  dataDrinkingOfTheDay.count > 0 {
                                            proxy.scrollTo(dataDrinkingOfTheDay.count - 1, anchor: .bottom)
                                            selectedIndex = dataDrinkingOfTheDay.count - 1
                                        }
                                    }
                                    .overlay {
                                        ZStack {
                                            Circle()
                                                .trim(from: 0.0, to: 1.0)
                                                .stroke(Color(#colorLiteral(red: 0.3114904165, green: 0.5568692684, blue: 0.7960240245, alpha: 1)), lineWidth: 4)
                                                .rotationEffect(.degrees(270))
                                            Circle()
                                                .trim(from: 0.0, to: (dataDrinkingOfTheDay.first(where: { $0.dayID == dataDrinkingOfTheDay[index].dateDrinkOfTheDay.yearMonthDay } )?.percentDrinking ?? 0) / 100)
                                                .stroke(Color(#colorLiteral(red: 0.933318913, green: 0.9332848787, blue: 0.9375355244, alpha: 1)), lineWidth: 4)
                                                .rotationEffect(.degrees(270))
                                                .animation(.easeInOut(duration: 1.0), value: (dataDrinkingOfTheDay.first(where: { $0.dayID == dataDrinkingOfTheDay[index].dateDrinkOfTheDay.yearMonthDay } )?.percentDrinking ?? 0) / 100)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                        }
                    }
                    if isEmptyRecordsToday() {
                        ContentUnavailableView("Упс! Пока здесь ничего нет...", systemImage: "waterbottle")
                    } else {
                        List {
                            ForEach(dataDrinking) { itemDataDrinking in
                                if itemDataDrinking.dateDrink.yearMonthDay == selectedDate.yearMonthDay {
                                    HistoryItemView(dataDrinking: itemDataDrinking, hydration: hydration[itemDataDrinking.nameDrink] ?? 1.0)
                                        .swipeActions(edge: .trailing) {
                                            Button("", systemImage: "trash") {
                                                withAnimation(.linear(duration: 0.4)) {
                                                    dataDrinkingOfTheDayViewModel.cancelDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: itemDataDrinking.amountDrink, percentDrinking: (Double(profile[0].lastAmountDrink) * (hydration[profile[0].lastNameDrink] ?? 1.0)) / profile[0].autoNormMl * 100)
                                                    dataDrinkingViewModel.deleteItemDataDrinking(modelContext: modelContext, itemDataDrinking: itemDataDrinking)
                                                    
                                                    if userDefaultsManager.isAuthorizationHealthKit {
                                                        healthKitManager.deleteWaterIntake(date: itemDataDrinking.dateDrink)
                                                    }
                                                }
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 3, trailing: 0))
                            .listRowBackground(Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1)))
                        }
                        .listStyle(.plain)
                    }
                }
            }
        }
        .onAppear {
            selectedWeek = Date().thisWeek
            selectedMonth = getAllDatesInCurrentMonth(date: Date())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("История")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func isEmptyRecordsToday() -> Bool {
        for item in dataDrinking {
            if item.dateDrink.yearMonthDay == selectedDate.yearMonthDay {
                return false
            }
        }
        return true
    }
    
    //Функция создания массива всех дат текущего месяца
    private func getAllDatesInCurrentMonth(date: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        
        // Получаем диапазон дат для текущего месяца
        if let range = calendar.range(of: .day, in: .month, for: date) {
            for day in range {
                var components = calendar.dateComponents([.year, .month], from: date)
                components.day = day
                if let date = calendar.date(from: components) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
}
    #Preview {
        StatisticsDrinkView()
    }
