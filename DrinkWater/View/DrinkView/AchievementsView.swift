//
//  AchievementsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 04.06.2024.
//

import SwiftUI
import AppMetricaCore

struct AchievementsView: View {
    @Binding var isAchievementShowingModal: Bool
    private let chooseIndexImageArray = [1, 7, 14, 30, 60, 90, 180, 270, 365]
    private let imagesAchievement = Constants.Back.Achievement.imagesAchievement
    private let namesAchievementFirst = Constants.Back.Achievement.namesAchievementFirst
    private let namesAchievementSecond = Constants.Back.Achievement.namesAchievementSecond
    
    @State private var isNetworkAvailable = false
    let monitor = NWPathMonitor()
    
    @State private var imageAchievement = ""
    @State private var nameAchievementFirst: LocalizedStringKey = ""
    @State private var nameAchievementSecond: LocalizedStringKey = ""
    
    @State private var showAchievementsModal = false
    
    private let  userDefaultsManager = UserDefaultsManager.shared
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                Text("Достижения")
                    .font(Constants.Design.Fonts.BodyLargeFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.white)
                Text("Ежедневная цель")
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                HStack {
                    VStack {
                        Image(userDefaultsManager.getBoolValueForUserDefaults("normDone") ?? false ? "Winning" : "DayAchievOff")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 100)
                        Text("Цель достигнута!")
                            .font(Constants.Design.Fonts.BodySmallFont)
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
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top)
                LazyVStack {
                    ForEach(0..<imagesAchievement.count, id: \.self) { index in
                        if index % 3 == 0 {
                            HStack(alignment: .bottom) {
                                ForEach(index..<min(index + 3, imagesAchievement.count), id: \.self) { innerIndex in
                                    VStack {
                                        ZStack {
                                            Image(userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0 >= chooseIndexImageArray[innerIndex] ? imagesAchievement[innerIndex] : "DayAchievOff")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 100)
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
                                                    .font(Constants.Design.Fonts.BodyMiniFont)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        Text(namesAchievementFirst[innerIndex])
                                            .font(Constants.Design.Fonts.BodySmallFont)
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
        .onAppear { startNetworkMonitoring() }
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isNetworkAvailable = path.status == .satisfied
                reportEventIfNetworkAvailable()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func reportEventIfNetworkAvailable() {
        if isNetworkAvailable {
            AppMetrica.reportEvent(name: "OpenView", parameters: ["AchievementsView": ""])
        } else {
            print("No network connection available. Cannot send event.")
        }
    }
}

#Preview {
    AchievementsView(isAchievementShowingModal: .constant(false))
}
