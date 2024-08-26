//
//  SmallWidgetView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import WidgetKit
import SwiftUI

struct SmallWidgetView: View {
    @AppStorage("com.alexander.l.DrinkWater.subscription.forever", store: UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")) var isPremium: Bool = false
    
    let entry: WidgetEntry
    let backgroundWidget = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2219799757, green: 0.7046170831, blue: 0.9977453351, alpha: 1).cgColor), Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1).cgColor)]), startPoint: .top, endPoint: .bottom)
    let amountMl: LocalizedStringKey = "мл"
    let amountOz: LocalizedStringKey = "унц"
    
    var body: some View {
        if !isPremium {
            Text("Необходима подписка!")
                .multilineTextAlignment(.center)
                .containerBackground(backgroundWidget, for: .widget)
        } else {
            let unit: String = entry.unit == 0 ? String(localized: "мл") : String(localized: "унц")
            ZStack {
                Circle()
                    .stroke(lineWidth: 7)
                    .foregroundColor(Color(.displayP3, red: 0.3114904165, green: 0.5568692684, blue: 0.7960240245, opacity: 1))
                
                Circle()
                    .trim(from: 0, to: CGFloat(entry.percentDrinking) / 100)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundColor(.white)
                    .rotationEffect(Angle(degrees: -90))
                
                VStack(alignment: .center, spacing: 8.0) {
                    Text("\(entry.amountDrink) \(unit)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Цель: \(entry.normDrink) \(unit)")
                        .font(.footnote)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 140, height: 140, alignment: .center)
            .containerBackground(backgroundWidget, for: .widget)
            //            .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2219799757, green: 0.7046170831, blue: 0.9977453351, alpha: 1).cgColor), Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1).cgColor)]), startPoint: .top, endPoint: .bottom))
        }
    }
}

#Preview {
    SmallWidgetView(entry: WidgetEntry(date: Date(), normDrink: 2000, amountDrink: 1000, percentDrinking: 50, nameDrink: "Water", unit: 0))
}
