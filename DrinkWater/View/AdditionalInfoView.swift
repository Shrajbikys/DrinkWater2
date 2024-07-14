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

struct AdditionalInfoView: View {
    @Environment(\.modelContext) private var modelContext
    
    private let userDefaultsManager = UserDefaultsManager.shared
    @State private var isAppleHealthPermissionAlert = false
    
    @State private var profileViewModel = ProfileViewModel()
    @State private var remindersViewModel = RemindersViewModel()
    
    @StateObject private var healthKitManager = HealthKitManager()
    
    @State private var isWeightShowingModal = false
    @State private var selectedNumber: Double = 30
    @State private var selectedUnitSegment: Int = 0
    @State private var isAppleHealthAuthorized = false
    @State private var isActivateSystemNotifications = false
    @State var gender: Gender
    
    @State private var isActive = false
    
    let unitSegments: Array<String> = ["кг | мл", "фн | унц"]
    
    var body: some View {
        ZStack {
            Image("BackgroundLS")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            VStack {
                Text("Укажите информацию для расчета суточной нормы употребления воды:")
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                VStack(spacing: 40) {
                    HStack {
                        Toggle(isOn: $isActivateSystemNotifications) {
                            Text("Уведомления:")
                        }
                    }
                    HStack{
                        Text("Вес:")
                        Spacer()
                        Button(action: {
                            isWeightShowingModal = true
                        }) {
                            Text("\( Int(selectedNumber) ) кг")
                                .bold()
                                .colorMultiply(.blue)
                        }
                        .sheet(isPresented: $isWeightShowingModal) {
                            WeightModalView(isWeightShowingModal: $isWeightShowingModal, selectedWeight: $selectedNumber, unitValue: selectedUnitSegment)
                                .presentationDetents([.height(250)])
                        }
                    }
                    HStack {
                        Toggle(isOn: $isAppleHealthAuthorized) {
                            Text("Здоровье:")
                        }
                        .tint(Color(#colorLiteral(red: 0.9215686275, green: 0.5058823529, blue: 0.4823529412, alpha: 1)))
                    }
                    .onChange(of: isAppleHealthAuthorized) { _, newValue in
                        userDefaultsManager.isAuthorizationHealthKit = newValue
                        isAppleHealthAuthorized = userDefaultsManager.isAuthorizationHealthKit
                        if isAppleHealthAuthorized {
                            requestHealthKitAuthorization()
                        }
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
                        Spacer()
                        Picker("Ед. измерения", selection: $selectedUnitSegment) {
                            ForEach(0..<unitSegments.count, id: \.self) { index in
                                Text(unitSegments[index]).tag(index)
                            }
                        }
                        .frame(width: 120)
                        .pickerStyle(.segmented)
                    }
                }
                Spacer()
                VStack {
                    Button(action: {
                        profileViewModel.createProfileForTheFirstLogin(modelContext: modelContext, gender: gender, weight: selectedNumber, unit: selectedUnitSegment)
                        remindersViewModel.firstLoadReminders(modelContext: modelContext)
                        userDefaultsManager.isFirstSign = true
                        isActive = true
                    }) {
                        VStack {
                            Image("startButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                            Text("Рассчитать норму")
                                .foregroundColor(.black)
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
}

//#Preview {
//    AdditionalInfoView(gender: .man)
//}
