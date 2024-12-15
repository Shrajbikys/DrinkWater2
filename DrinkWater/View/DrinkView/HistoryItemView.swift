//
//  HistoryItemView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 30.05.2024.
//

import SwiftUI

struct HistoryItemView: View {
    @EnvironmentObject var drinkProvider: DrinkDataProvider
    
    @State var dataDrinking: DataDrinking
    @State var hydration: Double
    @State var unit: Int
    
    private let backgroundDateDrinkTimeColor: Color = Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1))
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(white: 1, opacity: 0.1))
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width * 0.15)
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Image(dataDrinking.nameDrink)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }.padding(.leading, 5)
                VStack(alignment: .leading, spacing: 5) {
                    Text(drinkProvider.localizedName(forKey: dataDrinking.nameDrink) ?? "Water")
                        .lineLimit(1)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .foregroundStyle(.white)
                    Text(dataDrinking.dateDrink.timeOfHourAndMinutes)
                        .font(Constants.Design.Fonts.BodyMiniFont)
                        .foregroundStyle(backgroundDateDrinkTimeColor)
                }
                        Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(unit == 0 ? Double(dataDrinking.amountDrink).toStringMilli : Double(dataDrinking.amountDrink).toStringOunces)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .foregroundStyle(.white)
                        .padding(.trailing, 5)
                    Text("Гидратация = \(hydration.formatted(.percent))")
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
    HistoryItemView(dataDrinking: DataDrinking(nameDrink: "Water", amountDrink: 250, dateDrink: Date()), hydration: 1.0, unit: 0)
        .environmentObject(DrinkDataProvider())
}
