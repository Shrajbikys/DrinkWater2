//
//  CloudKitManager.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 06.07.2024.
//

import CloudKit
import SwiftData

@Observable
class CloudKitManager {
    
    private let container: CKContainer
    private let privateCloudDatabase: CKDatabase
    
    var dataDrinkingViewModel = DataDrinkingViewModel()
    var dataDrinkingOfTheDayViewModel = DataDrinkingOfTheDayViewModel()
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    let zone = CKRecordZone(zoneName: "UserZone")
    
    init() {
        self.container = CKContainer.default()
        self.privateCloudDatabase = container.privateCloudDatabase
    }
    
    func fetchAllRecords(recordType: String, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        privateCloudDatabase.fetch(withQuery: query, inZoneWith: zone.zoneID) { result in
            switch result {
            case .success((let matchResults, _)):
                var fetchedRecords: [CKRecord] = []
                for matchResult in matchResults {
                    switch matchResult.1 {
                    case .success(let record):
                        fetchedRecords.append(record)
                    case .failure(let error):
                        print(error)
                    }
                }
                DispatchQueue.main.async {
                    completion(fetchedRecords, nil)
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    private func deleteRecord(recordID: CKRecord.ID, completion: @escaping (Bool, Error?) -> Void) {
        privateCloudDatabase.delete(withRecordID: recordID) { (recordID, error) in
            DispatchQueue.main.async {
                completion(recordID != nil, error)
            }
        }
    }
    
    private func deleteAllRecords(recordType: String, completion: @escaping (Error?) -> Void) {
        fetchAllRecords(recordType: recordType) { (records, error) in
            guard let records = records, error == nil else {
                completion(error)
                return
            }
            
            let recordIDs = records.map { $0.recordID }
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
            
            operation.modifyRecordsResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
            self.privateCloudDatabase.add(operation)
        }
    }
    
    private func saveRecord(record: CKRecord, completion: @escaping (Bool, Error?) -> Void) {
        privateCloudDatabase.save(record) { (record, error) in
            DispatchQueue.main.async {
                completion(record != nil, error)
            }
        }
    }
    
    private func saveDrinkData(dataDrinking: [DataDrinking], progress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        let total = dataDrinking.count
        var saved = 0
        for item in dataDrinking {
            let recordId = CKRecord.ID(zoneID: zone.zoneID)
            let record = CKRecord(recordType: "DrinkData", recordID: recordId)
            
            record.setValue(item.nameDrink, forKey: "nameDrink")
            record.setValue(item.amountDrink, forKey: "amountDrink")
            record.setValue(item.dateDrink, forKey: "dateDrink")
            
            saveRecord(record: record) { (success, error) in
                if success {
                    saved += 1
                    progress(1)
                }
                if saved == total {
                    progress(1)
                    completion(true, nil)
                }
            }
        }
    }
    
    private func saveDrinkDataOfDay(dataDrinkingOfTheDay: [DataDrinkingOfTheDay], progress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        let total = dataDrinkingOfTheDay.count
        var saved = 0
        for item in dataDrinkingOfTheDay {
            let recordId = CKRecord.ID(zoneID: zone.zoneID)
            let record = CKRecord(recordType: "DrinkDataOfDay", recordID: recordId)
            let userDefaultsManager = UserDefaultsManager.shared
            let numberOfTheNorm = userDefaultsManager.getValueForUserDefaults("numberNorm") ?? 0
            record.setValue(item.dayID, forKey: "dayID")
            record.setValue(item.amountDrinkOfTheDay, forKey: "amountDrinkOfTheDay")
            record.setValue(item.dateDrinkOfTheDay, forKey: "dateDrinkOfTheDay")
            record.setValue(item.percentDrinking, forKey: "percentDrinked")
            record.setValue(numberOfTheNorm, forKey: "numberOfTheNorm")
            
            saveRecord(record: record) { (success, error) in
                if success {
                    saved += 1
                    progress(1)
                }
                if saved == total {
                    progress(1)
                    completion(true, nil)
                }
            }
        }
    }
    
    func deleteAllAndSave(dataDrinking: [DataDrinking], dataDrinkingOfTheDay: [DataDrinkingOfTheDay], saveProgress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        deleteAllRecords(recordType: "DrinkData") { (error) in
            if error == nil {
                self.deleteAllRecords(recordType: "DrinkDataOfDay") { (error) in
                    if error == nil {
                        self.saveDrinkData(dataDrinking: dataDrinking, progress: saveProgress) { (success, error) in
                            if success {
                                self.saveDrinkDataOfDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, progress: saveProgress, completion: completion)
                            } else {
                                completion(false, error)
                            }
                        }
                    } else {
                        completion(false, error)
                    }
                }
            } else {
                completion(false, error)
            }
        }
    }
}


extension CloudKitManager {
    private func fetchAndSaveDrinkData(modelContext: ModelContext, progress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "DrinkData", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = zone.zoneID
        var fetchedRecords: [CKRecord] = []

        queryOperation.recordMatchedBlock = { (recordID, recordResult) in
            switch recordResult {
            case .success(let record):
                let nameDrink = record.value(forKey: "nameDrink") as! String
                let amountDrink = record.value(forKey: "amountDrink") as! Int
                let dateDrink = record.value(forKey: "dateDrink") as! Date
                self.dataDrinkingViewModel.updateDataDrinking(modelContext: modelContext, nameDrink: nameDrink, amountDrink: amountDrink, dateDrink: dateDrink)
                progress(1)
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }
        
        queryOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error)
                }
            }
        }
        privateCloudDatabase.add(queryOperation)
    }
    
    private func fetchAndSaveDrinkDataOfDay(dataDrinkingOfTheDay: [DataDrinkingOfTheDay], modelContext: ModelContext, progress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "DrinkDataOfDay", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = zone.zoneID
        var fetchedRecords: [CKRecord] = []
        
        queryOperation.recordMatchedBlock = { (recordID, recordResult) in
            switch recordResult {
            case .success(let record):
                let amountDrinkOfTheDay = record.value(forKey: "amountDrinkOfTheDay") as! Int
                let dateDrinkOfTheDay = record.value(forKey: "dateDrinkOfTheDay") as! Date
                let percentDrinked = record.value(forKey: "percentDrinked") as! Double
                let numberOfTheNorm = record.value(forKey: "numberOfTheNorm") as! Int
                self.dataDrinkingOfTheDayViewModel.updateDataDrinkingOfTheDay(modelContext: modelContext, dataDrinkingOfTheDay: dataDrinkingOfTheDay, amountDrinkOfTheDay: amountDrinkOfTheDay, dateDrinkOfTheDay: dateDrinkOfTheDay, percentDrinking: percentDrinked)
                self.userDefaultsManager.setValueForUserDefaults(numberOfTheNorm, "numberNorm")
                progress(1)
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }
        
        queryOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error)
                }
            }
        }
        privateCloudDatabase.add(queryOperation)
    }
    
    func fetchAllDataAndSave(dataDrinkingOfTheDay: [DataDrinkingOfTheDay], modelContext: ModelContext, progress: @escaping (Int) -> Void, completion: @escaping (Bool, Error?) -> Void) {
        fetchAndSaveDrinkData(modelContext: modelContext) { savedCount in
            progress(savedCount)
        } completion: { success, error in
            if let error = error {
                completion(false, error)
                return
            }
            if success {
                self.fetchAndSaveDrinkDataOfDay(dataDrinkingOfTheDay: dataDrinkingOfTheDay, modelContext: modelContext) { savedCount in
                    progress(savedCount)
                } completion: { success, error in
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, error)
                    }
                }
            }
        }
    }
}
