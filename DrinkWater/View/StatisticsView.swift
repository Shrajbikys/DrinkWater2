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
import AppMetricaCore

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) private var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) private var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    
    @StateObject private var healthKitManager = HealthKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var dataDrinkingViewModel = DataDrinkingViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @State private var selectedSegment: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var isEmpty: Bool = true
    @State private var lastNameDrink: String = "Water"
    @State private var unit: Int = 0
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    private let backgroundChartColor: Color = Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1))
    private let backgroundExternalCircleColor: Color = Color(#colorLiteral(red: 0.3114904165, green: 0.5568692684, blue: 0.7960240245, alpha: 1))
    private let backgroundInternalCircleColor: Color = Color(#colorLiteral(red: 0.933318913, green: 0.9332848787, blue: 0.9375355244, alpha: 1))
    
    @State private var normDrink: Double = 2000
    let hydration: [String: Double] = Constants.Back.Drink.hydration
    
    let segments: Array<LocalizedStringKey> = ["Неделя", "Месяц"]
    
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
                backgroundViewColor
                    .ignoresSafeArea()
                VStack {
                    Picker("Days", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    HStack {
                        if selectedSegment == 0 {
                            Text("\(selectedWeek.first!.dayShort) \(selectedWeek.first!.abbreviatedMonth) - \(selectedWeek.last!.dayShort) \(selectedWeek.last!.abbreviatedMonth)")
                                .font(Constants.Design.Fonts.BodySmallFont)
                                .underline()
                                .foregroundStyle(.white)
                        } else {
                            Text("\(selectedMonth[0].fullMonth.capitalized) " + "\(selectedMonth[0].year)")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                                .underline()
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        HStack(spacing: 0) {
                            Button(action: {
                                if selectedSegment == 0 {
                                    selectedWeek = selectedWeek.first!.lastWeek
                                    AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "LastMonth"])
                                } else {
                                    selectedMonth = getAllDatesInCurrentMonth(date: selectedMonth.first!.lastMonthStart)
                                    AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "LasttMonth"])
                                }
                            }, label: {
                                Image(systemName: "arrow.left.circle")
                                    .foregroundStyle(.white)
                            })
                            .buttonBorderShape(.circle)
                            .buttonStyle(.bordered)
                            .foregroundStyle(.black)
                            
                            Button("Сегодня") {
                                if selectedSegment == 0 {
                                    selectedWeek = Date().thisWeek
                                } else {
                                    selectedMonth = getAllDatesInCurrentMonth(date: [Date().thisMonthStart, Date().thisMonthEnd].first!)
                                }
                                AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "Today"])
                            }
                            .frame(width: 95)
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.bordered)
                            .foregroundStyle(.white)
                            Button(action: {
                                if selectedSegment == 0 {
                                    selectedWeek = selectedWeek.first!.nextWeek
                                    AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "NextWeek"])
                                } else {
                                    selectedMonth = getAllDatesInCurrentMonth(date: selectedMonth.first!.nextMonthStart)
                                    AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "NextMonth"])
                                }
                            }, label: {
                                Image(systemName: "arrow.right.circle")
                                    .foregroundStyle(.white)
                            })
                            .buttonBorderShape(.circle)
                            .buttonStyle(.bordered)
                            .foregroundStyle(.black)
                        }
                    }
                    .padding(.horizontal, 20)
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
                        .chartYScale(domain: profile[0].unit == 0 ? 0...4000 : 0...150)
                        .chartYAxis(content: {
                            AxisMarks(position: .leading)
                        })
                        .foregroundStyle(backgroundChartColor)
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
                        .chartYScale(domain: profile[0].unit == 0 ? 0...4000 : 0...150)
                        .chartYAxis(content: {
                            AxisMarks(position: .leading)
                        })
                        .foregroundStyle(backgroundChartColor)
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    Text("Статистика за день")
                        .font(Constants.Design.Fonts.BodyLargeFont)
                        .foregroundStyle(.white)
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<dataDrinkingOfTheDay.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIndex = index
                                        selectedDate = dataDrinkingOfTheDay[index].dateDrinkOfTheDay
                                        AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "SelectedDate"])
                                    }, label: {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIndex == index ? backgroundExternalCircleColor : .clear)
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
                                                .stroke(backgroundExternalCircleColor, lineWidth: 4)
                                                .rotationEffect(.degrees(270))
                                            Circle()
                                                .trim(from: 0.0, to: (dataDrinkingOfTheDay.first(where: { $0.dayID == dataDrinkingOfTheDay[index].dateDrinkOfTheDay.yearMonthDay } )?.percentDrinking ?? 0) / 100)
                                                .stroke(backgroundInternalCircleColor, lineWidth: 4)
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
                                    HistoryItemView(dataDrinking: itemDataDrinking, hydration: hydration[itemDataDrinking.nameDrink] ?? 1.0, unit: profile[0].unit)
                                }
                            }
                            .onDelete(perform: { indexSet in
                                delete(at: indexSet)
                            })
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 3, trailing: 0))
                            .listRowBackground(backgroundViewColor)
                        }
                        .listStyle(.plain)
                    }
                }
            }
        }
        .onAppear {
            AppMetrica.reportEvent(name: "OpenView", parameters: ["StatisticsView": ""])
            
            selectedWeek = Date().thisWeek
            selectedMonth = getAllDatesInCurrentMonth(date: Date())
            
            lastNameDrink = profile[0].lastNameDrink
            unit = profile[0].unit
            if unit == 0 {
                normDrink = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
            } else {
                normDrink = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
            }
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
    
    private func sendDataToWidgetAndWatch() {
        let amountDrinkingOfTheDay: Int = dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.amountDrinkOfTheDay ?? 0
        let percentDrink: Double = dataDrinkingOfTheDay.first(where: { $0.dayID == Date().yearMonthDay } )?.percentDrinking.rounded(.toNearestOrAwayFromZero) ?? 0
        let isPremium = purchaseManager.hasPremium
        WidgetManager.sendDataToWidget(normDrink, amountDrinkingOfTheDay, percentDrink, lastNameDrink, unit, isPremium)
        
        let dateLastDrink = Date().dateFormatForWidgetAndWatch
        let amountUnit = unit == 0 ? "250" : "8"
        let iPhoneAppContext = ["normDrink": String(Int(normDrink)),
                                "amountDrink": String(amountDrinkingOfTheDay),
                                "percentDrink": String(Int(percentDrink)),
                                "amountUnit": amountUnit,
                                "unit": unit,
                                "dateLastDrink": dateLastDrink,
                                "isPremium": isPremium] as [String: Any]
        PhoneSessionManager.shared.sendAppContextToWatch(iPhoneAppContext)
        PhoneSessionManager.shared.transferCurrentComplicationUserInfo(iPhoneAppContext)
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            withAnimation(.linear(duration: 0.4)) {
                DispatchQueue.main.async {
                    let dataDrinkingItem = dataDrinking[offset]
                    let dataDrinkingOfTheDayItem = dataDrinkingOfTheDay.first(where: { $0.dayID == dataDrinkingItem.dateDrink.yearMonthDay } )
                    let amountDrinkOfTheDay = Int(Double(dataDrinkingItem.amountDrink) * (hydration[dataDrinkingItem.nameDrink] ?? 1.0))
                    let percentDrinking = (Double(dataDrinkingItem.amountDrink) * (hydration[dataDrinkingItem.nameDrink] ?? 1.0)) / normDrink * 100
                    dataDrinkingOfTheDayItem?.amountDrinkOfTheDay -= amountDrinkOfTheDay
                    dataDrinkingOfTheDayItem?.percentDrinking -= percentDrinking
                    
                    dataDrinkingViewModel.deleteItemDataDrinking(modelContext: modelContext, itemDataDrinking: dataDrinkingItem)
                    
                    sendDataToWidgetAndWatch()
                    
                    if userDefaultsManager.isAuthorizationHealthKit {
                        healthKitManager.deleteWaterIntake(date: dataDrinkingItem.dateDrink)
                    }
                    
                    AppMetrica.reportEvent(name: "StatisticsView", parameters: ["Press button": "Delete"])
                }
            }
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}
