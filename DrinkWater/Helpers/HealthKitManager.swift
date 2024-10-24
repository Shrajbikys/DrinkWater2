//
//  HealthKitSetupAssistant.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 27.02.2021.
//  Copyright © 2021 Alexander Lyubimov. All rights reserved.
//

import HealthKit

@Observable
class HealthKitManager {
    private var healthStore: HKHealthStore?
    var weight: Double?
    var biologicalSex: HKBiologicalSex?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorizationHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = healthStore else {
            completion(false, nil)
            return
        }
        
        let readTypes = Set([
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
            
        ])
        
        let writeTypes = Set([
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        ])
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    func saveWaterIntake(amount: Double, date: Date, unit: Int, completion: @escaping (Bool, Error?) -> Void) {
        
        var meta = [String: Any]()
        meta[HKMetadataKeySyncVersion] = 1
        meta[HKMetadataKeySyncIdentifier] = String(date.timeIntervalSince1970).split(separator: ".")[0]
        
        guard let healthStore = healthStore else {
            completion(false, nil)
            return
        }
        
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, nil)
            return
        }
        
        let waterQuantityLiter = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
        let waterQuantityOunce = HKQuantity(unit: .fluidOunceUS(), doubleValue: amount)
        let waterQuantity = unit == 0 ? waterQuantityLiter : waterQuantityOunce
        let waterSample = HKQuantitySample(
            type: waterType,
            quantity: waterQuantity,
            start: date,
            end: date,
            metadata: meta
        )
        
        healthStore.save(waterSample) { (success, error) in
            completion(success, error)
        }
    }
    
    func deleteWaterIntake(date: Date) {
        
        guard let dietaryWaterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            fatalError("Dietary Water Type is no longer available in HealthKit")
        }
        
        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySyncIdentifier, allowedValues: [String(date.timeIntervalSince1970).split(separator: ".")[0]])
        HKHealthStore().deleteObjects(of: dietaryWaterType, predicate: predicate) { _, _, error in
            if let error = error {
                print("Error Deleting BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully deleted BMI Sample")
            }
        }
    }
    
    func fetchWeight() {
        guard let healthStore = healthStore else { return }
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            if let error = error {
                print("Error fetching weight: \(error.localizedDescription)")
                return
            }
            
            guard let sample = results?.first as? HKQuantitySample else {
                print("No weight sample available")
                return
            }
            
            DispatchQueue.main.async {
                self.weight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            }
        }
        healthStore.execute(query)
    }
    
    func fetchBiologicalSex() {
        guard let healthStore = healthStore else { return }
        
        do {
            let biologicalSex = try healthStore.biologicalSex()
            DispatchQueue.main.async {
                self.biologicalSex = biologicalSex.biologicalSex
            }
        } catch {
            print("Error fetching biological sex: \(error.localizedDescription)")
        }
    }
}
