//
//  HistoryWeightView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 11.10.2024.
//

import SwiftUI
import SwiftData

struct HistoryWeightItemView: View {
    @Query(sort: \DataWeight.date, order: .forward) var dataWeight: [DataWeight]
    
    private let localizedNameDrinkHistory: [String: LocalizedStringKey] = Constants.Back.Drink.localizedNameDrinkHistory
    private let backgroundDateDrinkTimeColor: Color = Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1))
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    @State var unit: Int
    @State var weight: Double
    @State var date: Date
    @State var goal: Double
    @State var difference: Double
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(white: 1, opacity: 0.1))
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width * 0.15)
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Image(systemName: "vial.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .foregroundStyle(.white)
                }.padding(.leading, 5)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Вес: \(unit == 0 ? weight.toStringKg : weight.toStringPounds)")
                        .lineLimit(1)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .foregroundStyle(.white)
                    Text("Дата: \(date.formatDayMonthYear)")
                        .font(Constants.Design.Fonts.BodyMiniFont)
                        .foregroundStyle(backgroundDateDrinkTimeColor)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 0) {
                        Text("\(difference > 0 ? "+" :"")\(unit == 0 ? difference.toStringKg : difference.toStringPounds)")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(.white)
                            .padding(2)
                        Image(systemName: difference > 0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(difference > 0 ? .red : .green)
                    }
                    Text("Цель = \(unit == 0 ? goal.toStringKg : goal.toStringPounds)")
                        .font(Constants.Design.Fonts.BodyMiniFont)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HistoryWeightItemView(unit: 0, weight: 98, date: Date(), goal: 78, difference: -1.5)
}
