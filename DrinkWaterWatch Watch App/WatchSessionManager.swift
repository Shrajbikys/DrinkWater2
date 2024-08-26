//
//  WatchSessionManager.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import Foundation
import UserNotifications
import WatchConnectivity
import WatchKit
import WidgetKit
import SwiftUI

@Observable
class WatchSessionManager: NSObject {
    static let shared = WatchSessionManager()
    
    var response: String = ""
    
    var nameDrink: String = ""
    var normDrink: String = "0"
    var amountDrink: String = "0"
    var percentDrink: String = "0"
    var amountUnit: String = "0"
    var unit: String = "0"
    var isPremium: Bool = false
    var dateLastDrink: String = ""
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    public func sendMessageToApp(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            print("Отправка на айфон: \(message)")
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func processApplicationContext() {
        let dateNow: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateNow = dateFormatter.string(from: Date())
        
        if let userDefaultsWatch = UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch") {
            DispatchQueue.main.async {
                self.dateLastDrink = userDefaultsWatch.string(forKey: "dateLastDrink") ?? ""
                if dateNow != self.dateLastDrink {
                    userDefaultsWatch.set("0", forKey: "amountDrink")
                    userDefaultsWatch.set("0", forKey: "percentDrink")
                }
                self.normDrink = userDefaultsWatch.string(forKey: "normDrink") ?? "0"
                self.amountDrink = userDefaultsWatch.string(forKey: "amountDrink") ?? "0"
                self.percentDrink = userDefaultsWatch.string(forKey: "percentDrink") ?? "0"
                self.amountUnit = userDefaultsWatch.string(forKey: "amountUnit") ?? "0"
                self.unit = userDefaultsWatch.string(forKey: "unit") ?? "0"
                self.isPremium = userDefaultsWatch.bool(forKey: "isPremium")
                
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        if activationState == .activated {
            processApplicationContext()
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let userDefaultsWatch = UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch") {
                if let normDrink = applicationContext["normDrink"],
                   let amountDrink = applicationContext["amountDrink"],
                   let percentDrink = applicationContext["percentDrink"],
                   let amountUnit = applicationContext["amountUnit"],
                   let unit = applicationContext["unit"],
                   let dateLastDrink = applicationContext["dateLastDrink"],
                   let isPremium = applicationContext["isPremium"] {
                    
                    print("Получение данных с айфона (didReceiveApplicationContext): \(amountDrink)")
                    
                    userDefaultsWatch.set(normDrink, forKey: "normDrink")
                    userDefaultsWatch.set(amountDrink, forKey: "amountDrink")
                    userDefaultsWatch.set(percentDrink, forKey: "percentDrink")
                    userDefaultsWatch.set(amountUnit, forKey: "amountUnit")
                    userDefaultsWatch.set(unit, forKey: "unit")
                    userDefaultsWatch.set(dateLastDrink, forKey: "dateLastDrink")
                    userDefaultsWatch.set(isPremium, forKey: "isPremium")
                    
                    self.processApplicationContext()
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let userDefaultsWatch = UserDefaults(suiteName: "group.com.alexander.l.DrinkWater.Watch") {
                if let normDrink = userInfo["normDrink"],
                   let amountDrink = userInfo["amountDrink"],
                   let percentDrink = userInfo["percentDrink"],
                   let amountUnit = userInfo["amountUnit"],
                   let unit = userInfo["unit"],
                   let dateLastDrink = userInfo["dateLastDrink"],
                   let isPremium = userInfo["isPremium"] {
                    
                    print("Получение данных с айфона (didReceiveUserInfo): \(amountDrink)")
                    
                    userDefaultsWatch.set(normDrink, forKey: "normDrink")
                    userDefaultsWatch.set(amountDrink, forKey: "amountDrink")
                    userDefaultsWatch.set(percentDrink, forKey: "percentDrink")
                    userDefaultsWatch.set(amountUnit, forKey: "amountUnit")
                    userDefaultsWatch.set(unit, forKey: "unit")
                    userDefaultsWatch.set(dateLastDrink, forKey: "dateLastDrink")
                    userDefaultsWatch.set(isPremium, forKey: "isPremium")
                    
                    self.processApplicationContext()
                }
            }
        }
    }
}
