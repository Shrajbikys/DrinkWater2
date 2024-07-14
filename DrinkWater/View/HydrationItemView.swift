//
//  HydrationItemView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI

struct HydrationItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var nameDrink: String
    @State var imageDrink: String
    @State var hydration: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(colorScheme == .dark ? Color(white: 1, opacity: 0.1) : Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.2)))
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width * 0.13)
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Image(imageDrink)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .colorMultiply(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1)))
                }
                .padding(.leading, 5)
                Text(nameDrink)
                    .lineLimit(1)
                    .font(Constants.Design.AppFont.BodyMediumFont)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Spacer()
                Text("\(String(format: "%.1f", hydration))")
                    .font(Constants.Design.AppFont.BodyMediumFont)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(.trailing, 5)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HydrationItemView(nameDrink: "Water", imageDrink: "WaterSD", hydration: 1.0)
}
