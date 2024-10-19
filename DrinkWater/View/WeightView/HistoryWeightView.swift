//
//  DataWeightView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 09.10.2024.
//

import SwiftUI
import SwiftData

struct HistoryWeightView: View {
    @Query(sort: \DataWeight.date, order: .forward) var dataWeight: [DataWeight]
    
    @State private var selectedDate: Date = Date()
    @State var unit: Int
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                HStack {
                    Text("История веса")
                        .font(.largeTitle)
                    Spacer()
                }
                .padding([.top, .leading])
                YearMonthPickerView(selectedDate: $selectedDate)
                ScrollView {
                    ForEach(dataWeight) { item in
                        if item.date.monthYear() == selectedDate.monthYear() {
                            HistoryWeightItemView(unit: unit, weight: item.weight, date: item.date, goal: item.goal, difference: item.difference)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryWeightView(unit: 0)
}
