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
import StoreKit
import AppMetricaCore

struct SettingsView: View {
    @Query var profile: [Profile]
    @Query(sort: \DataDrinking.dateDrink, order: .forward) var dataDrinking: [DataDrinking]
    @Query(sort: \DataDrinkingOfTheDay.dateDrinkOfTheDay, order: .forward) var dataDrinkingOfTheDay: [DataDrinkingOfTheDay]
    @Query var reminder: [Reminder]
    
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    typealias SKTransaction = StoreKit.Transaction
    
    @State private var profileViewModel = ProfileViewModel()
    @State private var dataDrinkingViewModel = DataDrinkingViewModel()
    @State private var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var cloudKitManager = CloudKitManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    private let settingsListRowBackground = Constants.Design.Colors.settingsListRowBackground
    @State private var isWeightShowingModal = false
    @State private var isNormShowingModal = false
    @State private var selectedWeight: Double = 50
    @State private var selectedWeightFractional: Double = 0
    @State private var selectedNorm: Int = 2200
    @State private var selectedGenderSegment: Int = 0
    @State private var selectedUnitSegment: Int = 0
    @State private var isAuthorizationHealthKit = false
    @State private var isAppleHealthPermissionAlert = false
    @State private var isActivateAutoCalcSwitch = true
    @State private var isRemindersEnabled = false
    
    @State private var alertCloudMessage: LocalizedStringKey = ""
    
    @State private var isCloudExportAlert = false
    @State private var isCloudExportedAlert = false
    @State private var isCloudExported = false
    @State private var exportToCloudProgress = 0
    @State private var totalRecordsExportToCloud = 0
    @State private var progressExportCloudMessage: LocalizedStringKey = ""
    
    @State private var isCloudImportAlert = false
    @State private var isCloudImportedAlert = false
    @State private var isCloudImported = false
    @State private var importFromCloudProgress = 0
    @State private var totalRecordsImportFromCloud = 0
    @State private var progressImportCloudMessage: LocalizedStringKey = ""
    @State private var sliderValue: Double = 2200
    
    private let healthPickerColor: Color = Color(#colorLiteral(red: 0.9215686275, green: 0.5058823529, blue: 0.4823529412, alpha: 1))
    
    @State private var isPurchaseViewModal = false
    
    let genderSegments: Array<LocalizedStringKey> = ["Женский", "Мужской"]
    let unitSegments: Array<LocalizedStringKey> = ["кг | мл", "фн | унц"]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Вес")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        Button(action: {
                            isWeightShowingModal = true
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "SelectedWeight"])
                        }) {
                            Text(profile[0].unit == 0 ? profile[0].weightKg.toStringKg : profile[0].weightPounds.toStringPounds)
                                .bold()
                                .foregroundStyle(.link)
                        }
                        .sheet(isPresented: $isWeightShowingModal) {
                            let weight = profile[0].unit == 0 ? profile[0].weightKg : profile[0].weightPounds
                            let numberString = String(weight)
                            let parts = numberString.split(separator: ".")
                            let wholePart = Int(String(parts[0]))!
                            let fractionalPart = Int(String(parts[1]))!

                            WeightModalView(profile: profile, dataDrinkingOfTheDay: dataDrinkingOfTheDay, isWeightShowingModal: $isWeightShowingModal, selectedWeight: wholePart, selectedWeightFractional: fractionalPart, unitValue: selectedUnitSegment)
                                .presentationDetents([.height(250)])
                        }
                    }
                    HStack {
                        Text("Пол")
                            .font(Constants.Design.Fonts.BodyMediumFont)
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
                            profileViewModel.updateProfileGenderData(profile: profile, gender: index == 0 ? .girl : .man)
                            let autoNorm = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                            let customNorm = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            let percentDrinking = Double(dataDrinkingOfTheDay.last!.amountDrinkOfTheDay) / (profile[0].autoCalc ? autoNorm : customNorm) * 100
                            dataDrinkingOfTheDayViewModel.updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, percentDrinking: percentDrinking)
                            if profile[0].autoCalc {
                                sliderValue = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                            } else {
                                sliderValue = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            }
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "SelectedGender"])
                        }
                    }
                    HStack {
                        Text("Единицы измерения:")
                            .font(Constants.Design.Fonts.BodyMediumFont)
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
                            selectedWeight = index == 0 ? profile[0].weightKg : profile[0].weightPounds.rounded(.toNearestOrAwayFromZero)
                            if profile[0].autoCalc {
                                selectedNorm = index == 0 ? Int(profile[0].autoNormMl) : Int(profile[0].autoNormOz)
                                sliderValue = index == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                            } else {
                                selectedNorm = index == 0 ? Int(profile[0].customNormMl) : Int(profile[0].customNormOz)
                                sliderValue = index == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            }
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "SelectedUnit"])
                        }
                    }
                } header: {
                    Text("Основные настройки")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
                Section {
                    NavigationLink {
                        RemindersView(isRemindersEnabled: $isRemindersEnabled)
                    } label: {
                        HStack {
                            Text("Настройка уведомлений")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                            Spacer()
                            Text(isRemindersEnabled ? "Вкл" : "Выкл")
                                .font(Constants.Design.Fonts.BodySmallFont)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Уведомления")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ? settingsListRowBackground : .clear)
                Section {
                    HStack {
                        Toggle(isOn: $isActivateAutoCalcSwitch) {
                            Text("Рассчитать автоматически")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                        }
                        .onChange(of: isActivateAutoCalcSwitch) { _, value in
                            profileViewModel.updateProfileAutoCalcData(profile: profile, autoCalc: value)
                            if value {
                                sliderValue = profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz
                                selectedNorm = Int(profile[0].unit == 0 ? profile[0].autoNormMl : profile[0].autoNormOz)
                            } else {
                                sliderValue = profile[0].unit == 0 ? profile[0].customNormMl : profile[0].customNormOz
                            }
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "AutoCalcSwitch"])
                        }
                    }
                    HStack {
                        Text("Ваша норма")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                        Spacer()
                        Button(action: {
                            if !isActivateAutoCalcSwitch {
                                isNormShowingModal = true
                                AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "SelectedNorm"])
                            }
                        }) {
                            if profile[0].unit == 0 {
                                Text("\((profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl).toStringMilli)")
                                    .bold()
                                    .foregroundStyle(.link)
                            } else {
                                Text("\((profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz).toStringOunces)")
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
                    let percentDrinking = Double(dataDrinkingOfTheDay.last?.amountDrinkOfTheDay ?? 0) / customNorm * 100
                    dataDrinkingOfTheDayViewModel.updatePercentToDataDrinkingOfTheDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, percentDrinking: percentDrinking)
                }
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
                Section {
                    NavigationLink {
                        HydrationView()
                    } label: {
                        Text("Коэффициенты гидратации")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                    }
                } header: {
                    Text("Информация о напитках")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
                Section {
                    HStack {
                        Toggle(isOn: $isAuthorizationHealthKit) {
                            Text("Здоровье")
                                .font(Constants.Design.Fonts.BodyMediumFont)
                        }
                        .tint(healthPickerColor)
                    }
                } header: {
                    Text("Подключение Apple Health")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
                .onChange(of: isAuthorizationHealthKit) { _, newValue in
                    if purchaseManager.hasPremium {
                        userDefaultsManager.isAuthorizationHealthKit = newValue
                        isAuthorizationHealthKit = userDefaultsManager.isAuthorizationHealthKit
                        if isAuthorizationHealthKit {
                            requestHealthKitAuthorization()
                        }
                        AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "ActivateAppleHealth"])
                    } else {
                        isPurchaseViewModal = true
                        isAuthorizationHealthKit = false
                        AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "ActivateAppleHealthPurchase"])
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
                        if purchaseManager.hasPremium {
                            isCloudExportAlert = true
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "isCloudExport"])
                        } else {
                            isPurchaseViewModal = true
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "isCloudExportPurchase"])
                        }
                    }
                    .font(Constants.Design.Fonts.BodyMediumFont)
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
                        Text("Сейчас будет запущен процесс экспорта данных в iCloud. Вы хотите продолжить?")
                    }
                    .alert("iCloud", isPresented: $isCloudExportedAlert, actions: {
                        Button("OK", role: .cancel) {
                            isCloudExportedAlert = false
                        }
                    }, message: {
                        Text(alertCloudMessage)
                    })
                    Button("Импорт из iCloud") {
                        if purchaseManager.hasPremium {
                            isCloudImportAlert = true
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "isCloudImport"])
                        } else {
                            isPurchaseViewModal = true
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "isCloudImportPurchase"])
                        }
                    }
                    .font(Constants.Design.Fonts.BodyMediumFont)
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
                        VStack {
                            Text("Сейчас будет запущен процесс импорта данных из iCloud. Убедитесь, что ранее вы сделали экспорт в iCloud. Иначе вы можете потерять не сохраненные данные. Вы хотите продолжить?")
                        }
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
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
                Section {
                    Text("Восстановить покупки")
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .onTapGesture {
                            restore()
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "Restore"])
                        }
                    Text("Оценить приложение")
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .onTapGesture {
                            openAppStore()
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "Rate"])
                        }
                    ShareLink(item: "https://apple.co/3tB5ofx", message: Text("Приложение Drink Water помогает мне поддерживать необходимый уровень воды в организме. Рекомендую!")) {
                        Text("Поделиться")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                    }
                    Text("Написать в поддержку")
                        .font(Constants.Design.Fonts.BodyMediumFont)
                        .onTapGesture {
                            MailComposeViewController.shared.sendEmail()
                            AppMetrica.reportEvent(name: "SettingsView", parameters: ["Press button": "SendEmail"])
                        }
                    Link("Политика конфиденциальности", destination: URL(string: "https://telegra.ph/Privacy-Policy-02-17-9")!)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                    Link("Условия использования", destination: URL(string: "https://telegra.ph/Terms--Conditions-02-17")!)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                } header: {
                    Text("О приложении")
                        .textCase(.uppercase)
                }
                .listRowBackground(colorScheme == .dark ?  settingsListRowBackground : .clear)
            }
            .listStyle(.plain)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            AppMetrica.reportEvent(name: "OpenView", parameters: ["SettingsView": ""])
            
            selectedUnitSegment = profile[0].unit
            isActivateAutoCalcSwitch = profile[0].autoCalc
            isAuthorizationHealthKit = userDefaultsManager.isAuthorizationHealthKit
            isRemindersEnabled = reminder[0].reminderEnabled
            
            selectedGenderSegment = profile[0].gender == .girl ? 0 : 1
            if profile[0].unit == 0 {
                selectedNorm = profile[0].autoCalc ? Int(profile[0].autoNormMl) : Int(profile[0].customNormMl)
                sliderValue = profile[0].autoCalc ? profile[0].autoNormMl : profile[0].customNormMl
                selectedWeight = profile[0].weightKg
            } else {
                selectedNorm = profile[0].autoCalc ? Int(profile[0].autoNormOz) : Int(profile[0].customNormOz)
                sliderValue = profile[0].autoCalc ? profile[0].autoNormOz : profile[0].customNormOz
                selectedWeight = profile[0].weightPounds
            }
        }
        .sheet(isPresented: $isPurchaseViewModal) {
            PurchaseView(isPurchaseViewModal: $isPurchaseViewModal)
        }
        .overlay(content: {
            if isCloudExported || isCloudImported {
                Rectangle()
                    .foregroundStyle(Color.white.opacity(0.05))
            }
        })
        .blur(radius: isCloudExported || isCloudImported ? 5 : 0)
        .overlay(
            Group {
                if isCloudExported || isCloudImported {
                    VStack(spacing: 10) {
                        if isCloudExported {
                            Text(progressExportCloudMessage)
                                .bold()
                            Text("Сохранено записей: \(exportToCloudProgress)/\(totalRecordsExportToCloud)")
                        } else if isCloudImported {
                            Text(progressImportCloudMessage)
                                .bold()
                            Text("Сохранено записей: \(importFromCloudProgress)/\(totalRecordsImportFromCloud)")
                        }
                        ProgressView()
                        VStack(spacing: 2) {
                            Text("Пожалуйста, не закрывайте")
                                .foregroundStyle(.red)
                            Text("приложение")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        )
        .animation(.easeInOut, value: isCloudExported || isCloudImported)
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
                alertCloudMessage = "Экспорт успешно завершён!"
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
        
        cloudKitManager.fetchAllRecords(recordType: "DrinkData") { records, error in
            totalRecordsImportFromCloud += records?.count ?? 0
        }
        
        cloudKitManager.fetchAllRecords(recordType: "DrinkDataOfDay") { records, error in
            totalRecordsImportFromCloud += records?.count ?? 0
        }
        
        cloudKitManager.fetchAllDataAndSave(dataDrinkingOfTheDay: dataDrinkingOfTheDay, modelContext: modelContext, progress: { savedCount in
            progressImportCloudMessage = "Копируем данные..."
            importFromCloudProgress += savedCount
        }) { (success, error) in
            isCloudImported = false
            print("Data imported successfully")
            alertCloudMessage = "Импорт успешно завершён!"
            isCloudImportedAlert = true
        }
    }
    
    private func restore() {
        Task {
            do {
                try await purchaseManager.restorePurchases()
                
                if purchaseManager.hasPremium {
                    withAnimation {
                        print("Purchases restored")
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.previewContainer)
        .environment(PurchaseManager())
}
