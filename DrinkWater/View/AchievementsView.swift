//
//  AchievementsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.06.2024.
//

import SwiftUI

struct AchievementsView: View {
    @Binding var isAchievementShowingModal: Bool
    let chooseIndexImageArray = [1, 7, 14, 30, 60, 90, 180, 270, 365]
    let imagesAchievement = ["1DayAchiev", "7DaysAchiev", "14DaysAchiev", "30DaysAchiev", "60DaysAchiev", "90DaysAchiev", "180DaysAchiev", "270DaysAchiev", "365DaysAchiev"]
    let imagesAchievementOff = ["1DayAchievOff", "7DaysAchievOff", "14DaysAchievOff", "30DaysAchievOff", "60DaysAchievOff", "90DaysAchievOff", "180DaysAchievOff", "270DaysAchievOff", "365DaysAchievOff"]
    let namesAchievementFirst = ["Первый день", "7 дней", "14 дней", "30 дней", "60 дней", "90 дней", "180 дней", "270 дней", "365 дней"]
    let namesAchievementSecond = ["Начало положено!", "Смотри как легко!", "Только вперёд!", "Не останавливайся!", "Всегда стремись выше!", "Мотивация на уровне!", "Ты можешь больше!", "Всё возможно!", "Ты на вершине!"]
    
    @State private var imageAchievement = ""
    @State private var nameAchievementFirst = ""
    @State private var nameAchievementSecond = ""
    
    @State private var showAchievementsModal = false
    
    private let  userDefaultsManager = UserDefaultsManager.shared
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
                .ignoresSafeArea()
            VStack {
                Text("Достижения")
                    .font(Constants.Design.AppFont.BodyLargeFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.white)
                Text("Ежедневная цель")
                    .font(Constants.Design.AppFont.BodyMainFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                HStack {
                    VStack {
                        Image(userDefaultsManager.getBoolValueForUserDefaults("normDone") ?? false ? "Winning" : "WinningOff")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                        Text("Цель достигнута!")
                            .font(Constants.Design.AppFont.BodySmallFont)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(.white)
                Text("Награды")
                    .font(Constants.Design.AppFont.BodyMainFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                LazyVStack {
                    ForEach(0..<imagesAchievement.count, id: \.self) { index in
                        if index % 3 == 0 {
                            HStack(alignment: .bottom) {
                                ForEach(index..<min(index + 3, imagesAchievementOff.count), id: \.self) { innerIndex in
                                    VStack {
                                        ZStack {
                                            Image(userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0 >= chooseIndexImageArray[innerIndex] ? imagesAchievement[innerIndex] : imagesAchievementOff[innerIndex])
                                                .resizable()
                                                .scaledToFit()
                                                .onTapGesture {
                                                    withAnimation {
                                                        imageAchievement = imagesAchievement[innerIndex]
                                                        nameAchievementFirst = namesAchievementFirst[innerIndex]
                                                        nameAchievementSecond = namesAchievementSecond[innerIndex]
                                                        if userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0 >= chooseIndexImageArray[innerIndex] {
                                                            showAchievementsModal = true
                                                        }
                                                    }
                                                }
                                            if userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0 < chooseIndexImageArray[innerIndex] {
                                                Text("\(userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0)/\(chooseIndexImageArray[innerIndex])")
                                                    .font(Constants.Design.AppFont.BodyMiniFont)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        Text(namesAchievementFirst[innerIndex])
                                            .font(Constants.Design.AppFont.BodySmallFont)
                                            .foregroundStyle(.white)
                                            .bold()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .blur(radius: showAchievementsModal ? 10 : 0)
        .overlay(content: {
            if showAchievementsModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showAchievementsModal = false
                        }
                    }
                AchievementsModalView(showAchievementsModal: $showAchievementsModal, imageAchievement: imageAchievement, nameAchievementFirst: nameAchievementFirst, nameAchievementSecond: nameAchievementSecond)
            }
        })
    }
}

#Preview {
    AchievementsView(isAchievementShowingModal: .constant(false))
}
