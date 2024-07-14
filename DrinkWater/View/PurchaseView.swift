//
//  PurchaseView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 10.06.2024.
//

import SwiftUI

struct PurchaseView: View {
    private let title1 = ["Достижения", "Стильные виджеты", "Дополнительные напитки", "Интеграция с Apple Health", "Выбор звука уведомлений", "Приложение для Apple Watch", "Импорт/экспорт данных в iCloud", "Поддержите нас"]
    private let title2 = ["Пейте воду регулярно и достигайте новых высот", "Отслеживайте показатели выпитого за день не открывая приложение", "Какао, Смузи, Йогурт и другие напитки", "Автоматическое внесение данных в Apple Health", "Добавьте индивидуальности вашему уведомлению", "Вносите информацию и следите за количеством выпитого через Apple Watch", "Перенесите все данные, до последней капли, на новое устройство", "Ваша подписка очень мотивирует нас и помогает развитию Drink Water"]
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
                .ignoresSafeArea()
            ScrollView {
                Image("LogoPro")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("Полный доступ ко всем функциям приложения Drink Water")
                    .font(Constants.Design.AppFont.BodyLargeFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack(alignment: .leading) {
                    ForEach(0..<title1.count, id: \.self) { index in
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.yellow)
                                .frame(width: 50)
                            VStack(alignment: .leading) {
                                Text(title1[index])
                                    .font(Constants.Design.AppFont.BodyMediumFont)
                                    .bold()
                                    .foregroundStyle(.yellow)
                                Text(title2[index])
                                    .font(Constants.Design.AppFont.BodySmallFont)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                ZStack {
                    Image("PurchaseBox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170)
                    VStack(spacing: 5) {
                        Text("Drink Water Pro")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                            .foregroundStyle(.white)
                        Text("277,00 р")
                            .font(Constants.Design.AppFont.BodyLargeFont)
                            .bold()
                            .foregroundStyle(.white)
                        Text("Единоразово")
                            .font(Constants.Design.AppFont.BodyMiniFont)
                            .foregroundStyle(.white)
                        Button(action: {}, label: {
                            ZStack {
                                Image("PurchaseButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140)
                                Text("Продолжить")
                                    .foregroundStyle(.white)
                            }
                        })
                    }.padding(.top)
                }.padding(.bottom)
                VStack(spacing: 10) {
                    Text("Восстановить покупки")
                        .foregroundStyle(.link)
                    Text("Условия использования")
                        .foregroundStyle(.link)
                    Text("Политика конфиденциальности")
                        .foregroundStyle(.link)
                }
            }
        }
    }
}

#Preview {
    PurchaseView()
}
