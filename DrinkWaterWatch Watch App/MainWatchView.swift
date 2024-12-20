//
//  MainDrinkView.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import SwiftUI
import SwiftData

struct MainWatchView: View {
    @State private var isPremium: Bool = false
    
    @State private var model = WatchSessionManager.shared
    @State private var isShowingModal: Bool = false
    
    private let colorTop = Color(#colorLiteral(red: 0.2219799757, green: 0.7046170831, blue: 0.9977453351, alpha: 1).cgColor)
    private let colorBottom = Color(#colorLiteral(red: 0.2157807946, green: 0.4114688337, blue: 0.6079391837, alpha: 1).cgColor)
    private let watchBounds = WKInterfaceDevice.current().screenBounds
    private let watchHeight: CGFloat = 200
    
    var body: some View {
        VStack {
            if model.isPremium {
                VStack {
                    NavigationView {
                        VStack {
                            HStack {
                                VStack {
                                    Text("Выпито:").font(.system(size: watchBounds.height <= watchHeight ? 10 : 12))
                                    Text("\(model.unit == "0" ? Double(model.amountDrink)!.toStringMilli : Double(model.amountDrink)!.toStringOunces)").font(.system(size: watchBounds.height <= watchHeight ? 12 : 14))
                                    Text("")
                                    Text("Цель:").font(.system(size: watchBounds.height <= watchHeight ? 10 : 12))
                                    Text("\(model.unit == "0" ? Double(model.normDrink)!.toStringMilli : Double(model.normDrink)!.toStringOunces)").font(.system(size: watchBounds.height <= watchHeight ? 12 : 14))
                                }
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 10)
                                        .foregroundColor(Color(red: 0.0862745098, green: 0.09411764706, blue: 0.1058823529, opacity: 1))
                                    Circle()
                                        .trim(from: 0, to: CGFloat(Int(model.percentDrink)!) / 100)
                                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        .foregroundColor(Color(#colorLiteral(red: 0.3101733327, green: 0.5979617238, blue: 0.8022325635, alpha: 1).cgColor))
                                        .rotationEffect(Angle(degrees: -90))
                                    VStack(alignment: .center, spacing: 8.0) {
                                        Text((Int(model.percentDrink)?.formatted(.percent))!)
                                            .font(.custom("System", size: watchBounds.height <= watchHeight ? 15 : 16))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, watchBounds.height <= watchHeight ? 10 : 15)
                            .padding(.vertical)
                            HStack {
                                VStack {
                                    Button(action: {
                                        model.sendMessageToApp(["idOperation": UUID().uuidString, "nameDrink": "Water", "amountDrink": "250"])
                                    }, label: {
                                        Image("WaterWatch")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: watchBounds.height <= watchHeight ? 30 : 35)
                                    })
                                    .background(LinearGradient(gradient: Gradient(colors: [colorTop, colorBottom]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 10)
                                    .mask(Circle())
                                    Text("\(model.unit == "0" ? Double(250).toStringMilli : Double(8).toStringOunces)").font(.system(size: watchBounds.height <= watchHeight ? 9 : 11))
                                }
                                VStack{
                                    Button(action: {
                                        model.sendMessageToApp(["idOperation": UUID().uuidString, "nameDrink": "Tea", "amountDrink": "250"])
                                    }, label: {
                                        Image("TeaWatch")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 30)
                                    })
                                    .background(LinearGradient(gradient: Gradient(colors: [colorTop, colorBottom]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 10)
                                    .mask(Circle())
                                    
                                    Text("\(model.unit == "0" ? Double(250).toStringMilli : Double(8).toStringOunces)").font(.system(size: watchBounds.height <= watchHeight ? 9 : 11))
                                }
                                VStack{
                                    Button("+") {
                                        isShowingModal = true
                                    }
                                    .background(LinearGradient(gradient: Gradient(colors: [colorTop, colorBottom]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 10)
                                    .mask(Circle())
                                    .sheet(isPresented: $isShowingModal, content: {
                                        SelectDrinkView(model: model, isShowingModal: $isShowingModal)
                                    })
                                    Text("Добавить").font(.system(size: watchBounds.height <= watchHeight ? 9 : 11))
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Необходима подписка!")
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    MainWatchView()
}
