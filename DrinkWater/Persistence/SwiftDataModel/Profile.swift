//
//  Profile.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import SwiftData

@Model
final class Profile {
    var genderName: String = "Water"
    var gender: Constants.Back.Types.Gender {
        Constants.Back.Types.Gender(rawValue: genderName)!
    }
    var weightKg: Double = 50.0
    var heightCm: Double = 170.0
    var unit: Int = 0
    var autoNormMl: Double = 2000.0
    var customNormMl: Double = 2000.0
    var weightPounds: Double = 120.0
    var autoNormOz: Double = 8.0
    var customNormOz: Double = 8.0
    var autoCalc: Bool = true
    var lastAmountDrink: Int = 100
    var lastNameDrink: String = "Water"
    var lastSignIn: Date = Date().lastSignInDateFormatter
    
    init(gender: Constants.Back.Types.Gender = .man, weightKg: Double = 60.0, heightCm: Double = 170.0, unit: Int = 0, autoNormMl: Double = 2100.0, customNormMl: Double = 2100.0, weightPounds: Double = 132.0, autoNormOz: Double = 71.0095, customNormOz: Double = 71.0095, autoCalc: Bool = true, lastAmountDrink: Int = 100, lastNameDrink: String = "Water") {
        self.genderName = gender.rawValue
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.unit = unit
        self.autoNormMl = autoNormMl
        self.customNormMl = customNormMl
        self.weightPounds = weightPounds
        self.autoNormOz = autoNormOz
        self.customNormOz = customNormOz
        self.autoCalc = autoCalc
        self.lastAmountDrink = lastAmountDrink
        self.lastNameDrink = lastNameDrink
    }
}
