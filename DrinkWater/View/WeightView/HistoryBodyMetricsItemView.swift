//
//  HistoryBodyMetricsItemView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 11.10.2024.
//

import SwiftUI
import SwiftData

struct HistoryBodyMetricsItemView: View {
    private let backgroundDateDrinkTimeColor: Color = Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1))
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    @State var date: Date
    @State var unit: Int
    @State var chestSize: Double
    @State var waistSize: Double
    @State var hipSize: Double
    @State var differenceChestSize: Double
    @State var differenceWaistSize: Double
    @State var differenceHipSize: Double
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(white: 1, opacity: 0.1))
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width * 0.22)
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    VStack {
                        Image(systemName: "chart.line.text.clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .fontWeight(.thin)
                        Text(date.formatDayMonthYear)
                            .font(Constants.Design.Fonts.BodyMiniFont)
                            .foregroundStyle(backgroundDateDrinkTimeColor)
                    }
                    .padding(.horizontal, 5)
                }
                HStack(spacing: 5) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Грудь: ")
                        Text("Талия: ")
                        Text("Бёдра: ")
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(unit == 0 ? chestSize.toStringCm : chestSize.toStringInches)")
                        Text("\(unit == 0 ? waistSize.toStringCm : waistSize.toStringInches)")
                        Text("\(unit == 0 ? hipSize.toStringCm : hipSize.toStringInches)")
                    }
                }
                .lineLimit(1)
                .font(Constants.Design.Fonts.BodySmallFont)
                .foregroundStyle(.white)
                Spacer()
                VStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        Text("\(differenceChestSize > 0.0 ? "+" :"")\(unit == 0 ? differenceChestSize.toStringCm : differenceChestSize.toStringInches)")
                            .padding(2)
                        Image(systemName: differenceChestSize > 0.0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(differenceChestSize > 0.0 ? .red : .green)
                    }
                    HStack(spacing: 0) {
                        Text("\(differenceWaistSize > 0.0 ? "+" :"")\(unit == 0 ? differenceWaistSize.toStringCm : differenceWaistSize.toStringInches)")
                            .padding(2)
                        Image(systemName: differenceWaistSize > 0.0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(differenceWaistSize > 0.0 ? .red : .green)
                    }
                    HStack(spacing: 0) {
                        Text("\(differenceHipSize > 0.0 ? "+" :"")\(unit == 0 ? differenceHipSize.toStringCm : differenceHipSize.toStringInches)")
                            .padding(2)
                        Image(systemName: differenceHipSize > 0.0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(differenceHipSize > 0.0 ? .red : .green)
                    }
                }
                .font(Constants.Design.Fonts.BodySmallFont)
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HistoryBodyMetricsItemView(date: Date(), unit: 0, chestSize: 90.0, waistSize: 60.0, hipSize: 90.0, differenceChestSize: 0.0, differenceWaistSize: 0.0, differenceHipSize: 0.0)
}
