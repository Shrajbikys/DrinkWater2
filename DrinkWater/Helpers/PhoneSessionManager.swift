//
//  WatchManager.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import Foundation
import WatchConnectivity
import WidgetKit

@Observable
final class PhoneSessionManager: NSObject {
    static let shared = PhoneSessionManager()
    private var purchaseManager = PurchaseManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var idOperation: String = ""
    var nameDrink: String = ""
    var amountDrink: String = ""
    
    private override init() {
        super.init()
        
        guard WCSession.isSupported() else {
            return
        }
        
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    public func sendAppContextToWatch(_ iPhoneAppContext: [String: Any]) {
        guard WCSession.default.activationState == .activated else {
            return
        }
        if !purchaseManager.hasPremium {
            do {
                print("Отправка данных на часы (updateApplicationContext): \(iPhoneAppContext)")
                try WCSession.default.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    /// Функция отправки UserInfo для активации обновления Complication на Apple Watch
    public func transferCurrentComplicationUserInfo(_ userInfo: [String: Any]) {
        
        if WCSession.default.activationState == .activated && WCSession.default.isComplicationEnabled {
            print("Отправка данных на часы (transferCurrentComplicationUserInfo): \(userInfo)")
            WCSession.default.transferCurrentComplicationUserInfo(userInfo)
        }
    }
}

extension PhoneSessionManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if !purchaseManager.hasPremium {
            DispatchQueue.main.async {
                if let idOperation = message["idOperation"] as? String,
                   let nameDrink = message["nameDrink"] as? String,
                   let amountDrink = message["amountDrink"] as? String {
                    
                    print("Получение данных с часов (didReceiveMessage): \(message)")
                    
                    self.idOperation = idOperation
                    self.nameDrink = nameDrink
                    self.amountDrink = amountDrink
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
