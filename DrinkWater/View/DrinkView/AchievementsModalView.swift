//
//  AchievementsModalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 05.06.2024.
//

import SwiftUI
import AppMetricaCore

struct AchievementsModalView: View {
    @Binding var showAchievementsModal: Bool
    
    var imageAchievement: String
    var nameAchievementFirst: LocalizedStringKey
    var nameAchievementSecond: LocalizedStringKey
    
    private let backgroundShareLinkColor: Color = Color(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(imageAchievement)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                Button(action: {
                    showAchievementsModal = false
                }, label: {
                    Image("CloseButton")
                })
                .padding(.trailing, -10)
                .padding(.top, imageAchievement == "14DaysAchiev" ? 10 : -15)
            }
            VStack(spacing: 10) {
                Text(nameAchievementFirst)
                    .font(Constants.Design.Fonts.BodyTitle2Font)
                    .foregroundStyle(.white)
                    .bold()
                Text(nameAchievementSecond)
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .bold()
            }
            ShareLink(item: "https://apple.co/3tB5ofx", message: Text("Приложение Drink Water помогает мне поддерживать необходимый уровень воды в организме. Рекомендую!")) {
                Text("Поделиться")
                    .frame(maxWidth: .infinity, maxHeight: 10)
                    .padding()
                    .background(backgroundShareLinkColor)
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .foregroundStyle(.white)
                    .bold()
                    .cornerRadius(20)
            }
            if imageAchievement == "14DaysAchiev"{
                Button(action: {
                    let rateAppURL = "itms-apps://itunes.apple.com/us/app/id1555483060?action=write-review"
                    if let url = URL(string: rateAppURL), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                }) {
                    Text("Оценить приложение")
                        .frame(maxWidth: .infinity, maxHeight: 10)
                        .padding()
                        .background(backgroundShareLinkColor)
                        .font(Constants.Design.Fonts.BodyMainFont)
                        .foregroundStyle(.white)
                        .bold()
                        .cornerRadius(20)
                }
            }
        }
        .frame(maxWidth: 250, maxHeight: 400)
        .padding()
        .background(Gradient(colors: [Color(#colorLiteral(red: 0.2219799757, green: 0.7046170831, blue: 0.9977453351, alpha: 1)), Color(#colorLiteral(red: 0.3222017288, green: 0.522277236, blue: 0.7342401743, alpha: 1))]))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

#Preview {
    AchievementsModalView(showAchievementsModal: .constant(true), imageAchievement: "14DaysAchiev", nameAchievementFirst: "14 дней", nameAchievementSecond: "Только вперёд!")
}
