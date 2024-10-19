//
//  AdditionalInfoView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI
import SwiftData
import HealthKit
import AppMetricaCore

struct AdditionalInfoView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var profile: [Profile]
    
    private let userDefaultsManager = UserDefaultsManager.shared
    @State private var isAppleHealthPermissionAlert = false
    @State private var isAuthorizationSystemNotifications = false
    
    @State private var profileViewModel = ProfileViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    
    @StateObject private var healthKitManager = HealthKitManager()
    
    @State private var isWeightShowingModal = false
    @State private var selectedWeight: Double = 50
    @State private var selectedWeightFractional: Double = 0
    @State private var selectedUnitSegment: Int = 0
    @State private var isAppleHealthAuthorized = false
    @State private var isActivateSystemNotifications = false
    @State var gender: Constants.Back.Types.Gender
    
    private let healthPickerColor: Color = Color(#colorLiteral(red: 0.9215686275, green: 0.5058823529, blue: 0.4823529412, alpha: 1))
    @State private var isActive = false
    
    let unitSegments: Array<LocalizedStringKey> = ["кг | мл", "фн | унц"]
    
    var body: some View {
        ZStack {
            Image("BackgroundLS")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Text("Укажите информацию для расчёта суточной нормы употребления воды:")
                    .font(Constants.Design.Fonts.BodyMainFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                VStack(spacing: 40) {
                    HStack {
                        Toggle(isOn: $isActivateSystemNotifications) {
                            Text("Уведомления:")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                                .foregroundStyle(.white)
                        }
                        .onChange(of: isAuthorizationSystemNotifications) { _, newValue in
                            userDefaultsManager.isAuthorizationSystemNotifications = newValue
                            isAuthorizationSystemNotifications = userDefaultsManager.isAuthorizationSystemNotifications
                            if isAuthorizationSystemNotifications {
                                getPermissionSystemNotifications()
                            }
                            AppMetrica.reportEvent(name: "AdditionalInfoView", parameters: ["Press button": "ActivateSystemNotifications"])
                        }
                    }
                    HStack{
                        Text("Вес:")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Button(action: {
                            isWeightShowingModal = true
                            AppMetrica.reportEvent(name: "AdditionalInfoView", parameters: ["Press button": "SelectedWeight"])
                        }) {
                            if profile.isEmpty {
                                Text(selectedUnitSegment == 0 ? selectedWeight.toStringKg : selectedWeight.toStringPounds)
                                    .bold()
                                    .colorMultiply(.blue)
                            } else {
                                Text(profile[0].unit == 0 ? profile[0].weightKg.toStringKg : profile[0].weightPounds.toStringPounds)
                                    .bold()
                                    .colorMultiply(.blue)
                            }
                        }
                        .sheet(isPresented: $isWeightShowingModal) {
                            let weight = profile[0].unit == 0 ? profile[0].weightKg : profile[0].weightPounds
                            let numberString = String(weight)
                            let parts = numberString.split(separator: ".")
                            let wholePart = Int(String(parts[0]))!
                            let fractionalPart = Int(String(parts[1]))!
                            WeightModalView(profile: profile, isWeightShowingModal: $isWeightShowingModal, selectedWeight: wholePart, selectedWeightFractional: fractionalPart, unitValue: selectedUnitSegment)
                                .presentationDetents([.height(250)])
                        }
                    }
                    HStack {
                        Toggle(isOn: $isAppleHealthAuthorized) {
                            Text("Здоровье:")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                                .foregroundStyle(.white)
                        }
                        .tint(healthPickerColor)
                    }
                    .onChange(of: isAppleHealthAuthorized) { _, newValue in
                        userDefaultsManager.isAuthorizationHealthKit = newValue
                        isAppleHealthAuthorized = userDefaultsManager.isAuthorizationHealthKit
                        if isAppleHealthAuthorized {
                            requestHealthKitAuthorization()
                        }
                        AppMetrica.reportEvent(name: "AdditionalInfoView", parameters: ["Press button": "ActivateAppleHealth"])
                    }
                    .alert("Apple Health", isPresented: $isAppleHealthPermissionAlert) {
                        Button("Готово", role: .cancel) {
                            isAppleHealthPermissionAlert = false
                        }
                    } message: {
                        Text("Чтобы изменить разрешения для приложения 'Здоровье', пожалуйста предоставьте доступ: 'Настройки -> Здоровье -> Доступ к данным и устройства'.")
                    }
                    HStack {
                        Text("Ед. измерения:")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Ед. измерения", selection: $selectedUnitSegment) {
                            ForEach(0..<unitSegments.count, id: \.self) { index in
                                Text(unitSegments[index])
                                    .tag(index)
                            }
                        }
                        .frame(width: 120)
                        .pickerStyle(.segmented)
                        .onChange(of: selectedUnitSegment) { _, index in
                            profileViewModel.updateProfileUnitData(profile: profile, unit: index)
                            selectedWeight = index == 0 ? profile[0].weightKg : profile[0].weightPounds
                            
                            AppMetrica.reportEvent(name: "AdditionalInfoView", parameters: ["Press button": "SelectedUnit"])
                        }
                    }
                }
                Spacer()
                VStack {
                    Button(action: {
                            profileViewModel.updateProfileGenderData(profile: profile, gender: gender)
                            profileViewModel.updateProfileUnitData(profile: profile, unit: selectedUnitSegment)
                            AppMetrica.reportEvent(name: "AdditionalInfoView", parameters: ["Press button": "StartApp"])
                        userDefaultsManager.isFirstSign = true
                        userDefaultsManager.isMigration = true
                        isActive = true
                    }) {
                        VStack {
                            Image("startButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                            Text("Рассчитать норму")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .navigationDestination(isPresented: $isActive) {
                        MainView()
                    }
                }
            }
            .padding()
            .padding(.vertical, 50)
        }
        .onAppear {
            profileViewModel.createProfileForTheFirstLogin(modelContext: modelContext, gender: gender, weight: selectedWeight, unit: selectedUnitSegment)
            remindersViewModel.firstLoadReminders(modelContext: modelContext)
            
            if profile.isEmpty {
                selectedUnitSegment = 0
            } else {
                selectedUnitSegment = profile[0].unit
            }
            
            AppMetrica.reportEvent(name: "OpenView", parameters: ["AdditionalInfoView": ""])
        }
    }
    
    // Функция включения интеграции приложения с Apple Health
    private func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorizationHealthKit { (success, error) in
            guard success else {
                print("HealthKit Authorization Failed")
                return
            }
            getPermissionHealthKit()
            DispatchQueue.main.async {
                if userDefaultsManager.isAuthorizationHealthKit {
                    isAppleHealthAuthorized = true
                } else {
                    isAppleHealthAuthorized = false
                    isAppleHealthPermissionAlert = true
                }
            }
        }
    }

    private func getPermissionHealthKit() {
        if HKHealthStore().authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .dietaryWater)!) == .sharingAuthorized {
            updateAuthorizationHealthKit(true)
            print("Permission Granted to Access DietaryWater")
        } else {
            updateAuthorizationHealthKit(false)
            print("Permission Denied to Access DietaryWater")
        }
    }

    private func updateAuthorizationHealthKit(_ value: Bool) {
        userDefaultsManager.isAuthorizationHealthKit = value
    }
    
    private func getPermissionSystemNotifications() {
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus != .authorized {
                notificationsCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        updateAuthorizationSystemNotifications(true)
                        print("Request Authorization Notifications Success!")
                    } else if let error {
                        updateAuthorizationSystemNotifications(false)
                        print("Request Authorization Notifications Failed (\(error), \(error.localizedDescription))")
                    }
                }
            } else if settings.authorizationStatus == .denied {
                goToSettings()
            }
        })
    }
    
    private func updateAuthorizationSystemNotifications(_ value: Bool) {
        userDefaultsManager.isAuthorizationSystemNotifications = value
    }
    
    private func goToSettings(){
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:],
                                      completionHandler: nil)
        }
    }
}

#Preview {
    AdditionalInfoView(gender: .man)
        .modelContainer(PreviewContainer.previewContainer)
}
