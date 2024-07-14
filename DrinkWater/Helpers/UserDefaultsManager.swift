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

    var isFirstSign: Bool {
        get {
            return getBoolForKey(Keys.isFirstSign, defaultValue: false)
        }
        set {
            setValueForKey(newValue, forKey: Keys.isFirstSign)
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
    
    func setValueForUserDefaults(_ value: Any, _ key: String) {
        setValueForKey(value, forKey: key)
        widgetReloadAllTimelines()
    }

    func setCloudKitZoneForUserDefaults(_ value: Any, _ key: String) {
        setValueForKey(value, forKey: key)
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

    private init() {}
}

private extension UserDefaultsManager {

    struct Suites {
        static let suiteName = "group.com.alexander.l.DrinkWater"
    }

    struct Keys {
        static let isFirstSign = "isFirstSign"
        static let isAuthorizationHealthKit = "authorizationHealthKit"
        static let isAuthorizationICloud = "isAuthorizationICloud"
        static let isAuthorizationSystemNotifications = "isAuthorizationSystemNotifications"
    }

    func setValueForKey(_ value: Any, forKey key: String) {
        if let userDefaults = UserDefaults(suiteName: Suites.suiteName) {
            userDefaults.set(value, forKey: key)
        }
    }

    func getIntegerForKey(_ key: String) -> Int {
        if let userDefaults = UserDefaults(suiteName: Suites.suiteName) {
            return userDefaults.integer(forKey: key)
        } else {
            return 0
        }
    }

    func getBoolForKey(_ key: String, defaultValue: Bool) -> Bool {
        if let userDefaults = UserDefaults(suiteName: Suites.suiteName) {
            return userDefaults.bool(forKey: key)
        } else {
            return defaultValue
        }
    }
}
