//
//  HistoryItemView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 30.05.2024.
//

import SwiftUI

struct HistoryItemView: View {
    @State var dataDrinking: DataDrinking
    @State var hydration: Double
    
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
                    Text(dataDrinking.nameDrink)
                        .lineLimit(1)
                        .font(Constants.Design.AppFont.BodyMediumFont)
                        .foregroundStyle(.white)
                    Text(dataDrinking.dateDrink.timeOfHourAndMinutes)
                        .font(Constants.Design.AppFont.BodyMiniFont)
                        .foregroundStyle(Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)))
                }
                        Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(dataDrinking.amountDrink) мл")
                        .font(Constants.Design.AppFont.BodyMediumFont)
                        .foregroundStyle(.white)
                        .padding(.trailing, 5)
                    Text("Гидратация = \(Int(hydration*100))%")
                        .font(Constants.Design.AppFont.BodyMiniFont)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HistoryItemView(dataDrinking: DataDrinking(nameDrink: "Water", amountDrink: 250, dateDrink: Date()), hydration: 1.0)
}
