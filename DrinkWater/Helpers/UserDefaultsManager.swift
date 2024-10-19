//
//  UserDefaultsManager.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 11.03.2021.
//  Copyright © 2021 Alexander Lyubimov. All rights reserved.
//

import Foundation
import WidgetKit

class UserDefaultsManager {

    static let shared = UserDefaultsManager()

    private let userDefaults: UserDefaults
    
    private init() {
        userDefaults = UserDefaults(suiteName: "group.com.alexander.l.DrinkWater")!
    }
    
    var isFirstSign: Bool {
        get {
            return getBoolForKey(Keys.isFirstSign, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isFirstSign)
        }
    }

    var isFirstSignWidth: Bool {
        get {
            return getBoolForKey(Keys.isFirstSignWidth, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isFirstSignWidth)
        }
    }

    var isMigration: Bool {
        get {
            return getBoolForKey(Keys.isMigration, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isMigration)
        }
    }

    var isAuthorizationHealthKit: Bool {
        get {
            return getBoolForKey(Keys.isAuthorizationHealthKit, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isAuthorizationHealthKit)
        }
    }

    var isAuthorizationICloud: Bool {
        get {
            return getBoolForKey(Keys.isAuthorizationICloud, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isAuthorizationICloud)
        }
    }

    var isAuthorizationSystemNotifications: Bool {
        get {
            return getBoolForKey(Keys.isAuthorizationSystemNotifications, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isAuthorizationSystemNotifications)
        }
    }
    
    var hasPremium: Bool {
        get {
            return getBoolForKey(Keys.hasPremium, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.hasPremium)
        }
    }
    
    func setValueForUserDefaults(_ value: Any, _ key: String) {
        setValueForKey(value, forKey: key)
        widgetReloadAllTimelines()
    }

    func setCloudKitZoneForUserDefaults(_ value: Any, _ key: String) {
        setValueForKey(value, forKey: key)
    }

    func getStringValueForUserDefaults(_ key: String) -> String? {
        return getStringForKey(key)
    }
    
    func getValueForUserDefaults(_ key: String) -> Int? {
        return getIntegerForKey(key)
    }

    func getBoolValueForUserDefaults(_ key: String) -> Bool? {
        return getBoolForKey(key, defaultValue: false)
    }

    private func widgetReloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private extension UserDefaultsManager {

    struct Keys {
        static let isMigration = "isMigration"
        static let isFirstSign = "isFirstSign"
        static let isFirstSignWidth = "isFirstSignWidth"
        static let isAuthorizationHealthKit = "authorizationHealthKit"
        static let isAuthorizationICloud = "isAuthorizationICloud"
        static let isAuthorizationSystemNotifications = "isAuthorizationSystemNotifications"
        static let hasPremium = "com.alexander.l.DrinkWater.subscription.forever"
    }

    func setValueForKey(_ value: Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getStringForKey(_ key: String) -> String {
        userDefaults.string(forKey: key) ?? ""
    }
    
    func getIntegerForKey(_ key: String) -> Int {
        userDefaults.integer(forKey: key)
    }

    func getBoolForKey(_ key: String, defaultValue: Bool) -> Bool {
        userDefaults.bool(forKey: key)
    }
}
