//
//  SettingsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 02.06.2024.
//

import SwiftUI
import SwiftData
import HealthKit
import PushKit
import CloudKit

struct SettingsView: View {
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    @Query var reminder: [Reminder]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileViewModel = ProfileViewModel()
    @State private var dataDrinkingViewModel = DataDrinkingViewModel()
    @State private var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var cloudKitManager = CloudKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    @State private var isWeightShowingModal = false
    @State private var isNormShowingModal = false
    @State private var selectedWeight: Double = 50
    @State private var selectedNorm: Int = 2200
    @State private var selectedGenderSegment: Int = 0
    @State private var selectedUnitSegment: Int = 0
    @State private var isAuthorizationHealthKit = false
    @State private var isAppleHealthPermissionAlert = false
    @State private var isActivateAutoCalcSwitch = true
    @State private var isRemindersEnabled = false
    
    @State private var alertCloudMessage = ""
    
    @State private var isCloudExportAlert = false
    @State private var isCloudExportedAlert = false
    @State private var isCloudExported = false
    @State private var exportToCloudProgress = 0
    @State private var totalRecordsExportToCloud = 0
    @State private var progressExportCloudMessage = ""
    
    @State private var isCloudImportAlert = false
    @State private var isCloudImportedAlert = false
    @State private var isCloudImported = false
    @State private var importFromCloudProgress = 0
    @State private var totalRecordsImportFromCloud = 0
    @State private var progressImportCloudMessage = ""
    
    @State private var sliderValue: Double = 2200
    
    let genderSegments: Array<String> = ["Женский", "Мужской"]
    let unitSegments: Array<String> = ["кг | мл", "фн | унц"]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Вес")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                        Spacer()
                        Button(action: {
                            isWeightShowingModal = true
                        }) {
                            if profile[0].unit == 0 {
                                Text("\(Int(profile[0].weightKg)) кг")
                                    .bold()
                                    .foregroundStyle(.link)
                            } else {
                                Text("\(Int(profile[0].weightPounds)) фн")
                                    .bold()
                                    .foregroundStyle(.link)
                            }
                        }
                        .sheet(isPresented: $isWeightShowingModal) {
                            WeightModalView(profile: profile, dataDrinkingOfTheDay:  dataDrinkingOfTheDay, isWeightShowingModal: $isWeightShowingModal, selectedWeight: $selectedWeight, unitValue: selectedUnitSegment)
                                .presentationDetents([.height(250)])
                        }
                    }
                    HStack {
                        Text("Пол")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                        Spacer()
                        Picker("Пол", selection: $selectedGenderSegment) {
                            ForEach(0..<genderSegments.count, id: \.self) { index in
                                Text(genderSegments[index])
                                    .tag(index)
                            }
                        }
                        .frame(width: 150)
                        .pickerStyle(.segmented)
                        .onChange(of: selectedGenderSegment) { _, index in
                            profileViewModel.updateProfileGenderData(profile: profile, gender: index == 0 ? Gender.girl : Gender.man)
                            let autoNorm = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                            let percentDrinking = Double(dataDrinkingOfTheDay.last!.amountDrinkOfTheDay) / autoNorm * 100
                            dataDrinkingOfTheDayViewModel.updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, percentDrinking: percentDrinking)
                        }
                    }
                    HStack {
                        Text("Единицы измерения:")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                        Spacer()
                        Picker("Ед. измерения", selection: $selectedUnitSegment) {
                            ForEach(0..<unitSegments.count, id: \.self) { index in
                                Text(unitSegments[index])
                                    .tag(index)
                            }
                        }
                        .frame(width: 150)
                        .pickerStyle(.segmented)
                        .onChange(of: selectedUnitSegment) { _, index in
                            profileViewModel.updateProfileUnitData(profile: profile, unit: index)
                            if profile[0].autoCalc {
                                sliderValue = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                            } else {
                                sliderValue = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            }
                        }
                    }
                } header: {
                    Text("Основные настройки")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                Section {
                    NavigationLink {
                        RemindersView(isRemindersEnabled: $isRemindersEnabled)
                    } label: {
                        HStack {
                            Text("Настройка уведомлений")
                                .font(Constants.Design.AppFont.BodyMediumFont)
                            Spacer()
                            Text(isRemindersEnabled ? "Вкл" : "Выкл")
                                .font(Constants.Design.AppFont.BodySmallFont)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Уведомления")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                Section {
                    HStack {
                        Toggle(isOn: $isActivateAutoCalcSwitch) {
                            Text("Рассчитать автоматически")
                                .font(Constants.Design.AppFont.BodyMediumFont)
                        }
                        .onChange(of: isActivateAutoCalcSwitch) { _, value in
                            profileViewModel.updateProfileAutoCalcData(profile: profile, autoCalc: value)
                            if value {
                                sliderValue = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                                selectedNorm = Int(profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz)
                            } else {
                                sliderValue = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            }
                        }
                    }
                    HStack {
                        Text("Ваша норма")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                        Spacer()
                        Button(action: {
                            if !isActivateAutoCalcSwitch {
                                isNormShowingModal = true
                            }
                        }) {
                            if profile[0].unit == 0 {
                                Text("\(Int(profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl)) мл")
                                    .bold()
                                    .foregroundStyle(.link)
                            } else {
                                Text("\(Int(profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz)) унц")
                                    .bold()
                                    .foregroundStyle(.link)
                            }
                        }
                        .sheet(isPresented: $isNormShowingModal) {
                            NormModalView(profile: profile, isNormShowingModal: $isNormShowingModal, selectedNorm: $selectedNorm, sliderValue: $sliderValue)
                                .presentationDetents([.height(250)])
                        }
                    }
                    Slider(
                        value: $sliderValue,
                        in: profile[0].unit == 0 ? 100...4000 : 0...140,
                        step: profile[0].unit == 0 ? 100 : 2
                    ).disabled(isActivateAutoCalcSwitch)
                } header: {
                    Text("Норма воды в день")
                        .textCase(.uppercase)
                }
                .onChange(of: sliderValue) { _, value in
                    profileViewModel.updateProfileCustomNormData(profile: profile, customNorm: sliderValue)
                    selectedNorm = Int(profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz)
                    let customNorm = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                    let percentDrinking = Double(dataDrinkingOfTheDay.last!.amountDrinkOfTheDay) / customNorm * 100
                    dataDrinkingOfTheDayViewModel.updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, percentDrinking: percentDrinking)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                Section {
                    NavigationLink {
                        HydrationView()
                    } label: {
                        Text("Коэффициенты гидратации")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                    }
                } header: {
                    Text("Информация о напитках")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                Section {
                    HStack {
                        Toggle(isOn: $isAuthorizationHealthKit) {
                            Text("Здоровье")
                                .font(Constants.Design.AppFont.BodyMediumFont)
                        }
                        .tint(Color(#colorLiteral(red: 0.9215686275, green: 0.5058823529, blue: 0.4823529412, alpha: 1)))
                    }
                } header: {
                    Text("Подключение Apple Health")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                .onChange(of: isAuthorizationHealthKit) { _, newValue in
                    userDefaultsManager.isAuthorizationHealthKit = newValue
                    isAuthorizationHealthKit = userDefaultsManager.isAuthorizationHealthKit
                    if isAuthorizationHealthKit {
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
                Section {
                    Button("Экспорт в iCloud") {
                        isCloudExportAlert = true
                    }
                    .font(Constants.Design.AppFont.BodyMediumFont)
                    .foregroundStyle(.link)
                    .alert("Предупреждение", isPresented: $isCloudExportAlert) {
                        Button("Да", role: .destructive) {
                            isCloudExportAlert = false
                            exportToCloud()
                        }
                        Button("Нет", role: .cancel) {
                            isCloudExportAlert = false
                        }
                    } message: {
                        Text("All previously saved data will be cleared. Do you want to continue?")
                    }
                    .alert("iCloud", isPresented: $isCloudExportedAlert, actions: {
                        Button("OK", role: .cancel) {
                            isCloudExportedAlert = false
                        }
                    }, message: {
                        Text(alertCloudMessage)
                    })
                    Button("Импорт из iCloud") {
                        isCloudImportAlert = true
                    }
                    .font(Constants.Design.AppFont.BodyMediumFont)
                    .foregroundStyle(.link)
                    .alert("Предупреждение", isPresented: $isCloudImportAlert) {
                        Button("Да", role: .destructive) {
                            isCloudImportAlert = false
                            importFromCloud()
                        }
                        Button("Нет", role: .cancel) {
                            isCloudImportAlert = false
                        }
                    } message: {
                        Text("All previously saved data will be cleared. Do you want to continue?")
                    }
                    .alert("iCloud", isPresented: $isCloudImportedAlert, actions: {
                        Button("OK", role: .cancel) {
                            isCloudImportedAlert = false
                        }
                    }, message: {
                        Text(alertCloudMessage)
                    })
                } header: {
                    Text("Синхронизация с ICloud")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
                Section {
                    Text("Восстановить покупки")
                        .font(Constants.Design.AppFont.BodyMediumFont)
                    Text("Оценить приложение")
                        .font(Constants.Design.AppFont.BodyMediumFont)
                        .onTapGesture {
                            openAppStore()
                        }
                    ShareLink(item: "https://apple.co/3tB5ofx", message: Text("Приложение Drink Water помогает мне поддерживать необходимый уровень воды в организме. Рекомендую!")) {
                        Text("Поделиться")
                            .font(Constants.Design.AppFont.BodyMediumFont)
                    }
                    Text("Написать в поддержку")
                        .font(Constants.Design.AppFont.BodyMediumFont)
                        .onTapGesture {
                            MailComposeViewController.shared.sendEmail()
                        }
                    Link("Конфиденциальность", destination: URL(string: "https://telegra.ph/Privacy-Policy-02-17-9")!)
                        .font(Constants.Design.AppFont.BodyMediumFont)
                    Link("Условия использования", destination: URL(string: "https://telegra.ph/Terms--Conditions-02-17")!)
                        .font(Constants.Design.AppFont.BodyMediumFont)
                } header: {
                    Text("О приложении")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1)) : .clear)
            }
            .listStyle(.plain)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            selectedUnitSegment = profile[0].unit
            isActivateAutoCalcSwitch = profile[0].autoCalc
            isAuthorizationHealthKit = userDefaultsManager.isAuthorizationHealthKit
            isRemindersEnabled = reminder[0].reminderEnabled
            
            selectedGenderSegment = profile[0].gender == .girl ? 0 : 1
            if profile[0].unit == 0 {
                selectedNorm = Int(profile[0].autoNormMl)
                sliderValue = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                selectedWeight = profile[0].weightKg
            } else {
                selectedNorm = Int(profile[0].autoNormOz)
                sliderValue = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                selectedWeight = profile[0].weightPounds
            }
        }
        .overlay(
            Group {
                if isCloudExported {
                    VStack(spacing: 20) {
                        Text(progressExportCloudMessage)
                        Text("Сохранено записей: \(exportToCloudProgress)/\(totalRecordsExportToCloud)")
                        ProgressView()
                        Text("Не закрывайте приложение")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        )
        .animation(.easeInOut, value: isCloudExported)
        .overlay(
            Group {
                if isCloudImported {
                    VStack(spacing: 20) {
                        Text(progressImportCloudMessage)
                        Text("Сохранено записей: \(importFromCloudProgress)/\(totalRecordsImportFromCloud)")
                        ProgressView()
                        Text("Не закрывайте приложение")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        )
        .animation(.easeInOut, value: isCloudImported)
    }
    
    func openAppStore() {
        let rateAppURL = "itms-apps://itunes.apple.com/us/app/id1555483060?action=write-review"
        if let url = URL(string: rateAppURL), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
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
                    isAuthorizationHealthKit = true
                } else {
                    isAuthorizationHealthKit = false
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
    
    private func exportToCloud() {
        isCloudExported = true
        exportToCloudProgress = 0
        totalRecordsExportToCloud = dataDrinking.count + dataDrinkingOfTheDay.count
        progressExportCloudMessage = "Очистка кэша..."
        cloudKitManager.deleteAllAndSave(dataDrinking: dataDrinking, dataDrinkingOfTheDay: dataDrinkingOfTheDay, saveProgress: { savedCount in
            progressExportCloudMessage = "Экспорт данных..."
            exportToCloudProgress += savedCount
        }) { (success, error) in
            isCloudExported = false
            if success {
                print("Data exported successfully")
                alertCloudMessage = "Экспорт успешно завершен!"
                isCloudExportedAlert = true
            } else {
                print("Error saving data: \(error?.localizedDescription ?? "Unknown error")")
            }
            isCloudExportedAlert = true
        }
    }
    
    private func importFromCloud() {
        isCloudImported = true
        importFromCloudProgress = 0
        totalRecordsImportFromCloud = 0
        progressImportCloudMessage = "Сбор данных..."
        dataDrinkingViewModel.deleteAllDataDataDrinking(modelContext: modelContext)
        dataDrinkingOfTheDayViewModel.deleteAllDataDataDrinkingOfTheDay(modelContext: modelContext)
        
        cloudKitManager.fetchAllDataAndSave(dataDrinkingOfTheDay: dataDrinkingOfTheDay, modelContext: modelContext, progress: { savedCount in
            progressImportCloudMessage = "Копируем данные..."
            importFromCloudProgress += savedCount
        }) { (success, error) in
            isCloudImported = false
            print("Data imported successfully")
            alertCloudMessage = "Импорт успешно завершен!"
            isCloudImportedAlert = true
        }
    }
}

#Preview {
    SettingsView()
}
