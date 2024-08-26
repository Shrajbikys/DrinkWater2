//
//  MediumWidgetView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import SwiftUI

struct MediumWidgetView: View {
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
            let amount250: Int = entry.unit == 0 ? 250 : Int(Measurement(value: 250, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value)
            let amount300: Int = entry.unit == 0 ? 300 : Int(Measurement(value: 300, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value)
            let amount350: Int = entry.unit == 0 ? 350 : Int(Measurement(value: 350, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value)
            
            HStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .foregroundColor(Color(.displayP3, red: 0.3114904165, green: 0.5568692684, blue: 0.7960240245, opacity: 1))
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.percentDrinking) / 100)
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: -90))
                    
                    Text("\(entry.percentDrinking.formatted(.percent))")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer(minLength: 15)
                VStack(spacing: 5) {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text ("Выпито: \(entry.amountDrink) \(unit)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text ("Цель: \(entry.normDrink) \(unit)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                    HStack(spacing: 10.0) {
                        VStack(spacing: 2.0) {
                            Link(destination: URL(string: "drinkwaterapp://\(amount250)")!) {
                                Image(entry.nameDrink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text ("\(amount250)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        VStack(spacing: 2.0) {
                            Link(destination: URL(string: "drinkwaterapp://\(amount300)")!) {
                                Image(entry.nameDrink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text ("\(amount300)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        VStack(spacing: 2.0) {
                            Link(destination: URL(string: "drinkwaterapp://\(amount350)")!) {
                                Image(entry.nameDrink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text ("\(amount350)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .containerBackground(backgroundWidget, for: .widget)
            .padding(-5)
            //            .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2219799757, green: 0.7046170831, blue: 0.9977453351, alpha: 1).cgColor), Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1).cgColor)]), startPoint: .top, endPoint: .bottom))
        }
    }
}

#Preview {
    MediumWidgetView(entry: WidgetEntry(date: Date(), normDrink: 2100, amountDrink: 1000, percentDrinking: 50, nameDrink: "Water", unit: 0))
}
