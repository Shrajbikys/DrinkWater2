//
//  ProfileViewModel.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.06.2024.
//

import Foundation
import Observation
import SwiftData

@Observable
class ProfileViewModel {
    
    func createProfileForTheFirstLogin(modelContext: ModelContext, gender: Constants.Back.Types.Gender, weight: Double, unit: Int) {
        var weightKg: Double
        var weightPounds: Double
        var autoNormMl: Double
        var autoNormOz: Double
        
        let indexWeight = gender == .girl ? 31.0 : 35.0

        if unit == 0 {
            weightKg = weight
            weightPounds = Measurement(value: weightKg, unit: UnitMass.kilograms).converted(to: .pounds).value
        } else {
            weightKg = Measurement(value: weight, unit: UnitMass.pounds).converted(to: .kilograms).value
            weightPounds = weight
        }
        
        autoNormMl = 100*round(weightKg*indexWeight/100)
        autoNormOz = Measurement(value: autoNormMl, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value
        
        let profile = Profile()
        profile.genderName = gender.rawValue
        profile.unit = unit
        profile.weightKg = weightKg
        profile.weightPounds = weightPounds
        profile.autoNormMl = autoNormMl
        profile.customNormMl = autoNormMl
        profile.autoNormOz = autoNormOz
        profile.customNormOz = autoNormOz
        
        modelContext.insert(profile)
    }
    
    func updateProfileDrinkData(profile: [Profile], lastNameDrink: String, lastAmountDrink: Int) {
        profile[0].lastNameDrink = lastNameDrink
        profile[0].lastAmountDrink = lastAmountDrink
    }
    
    func updateProfileWeightData(profile: [Profile], weight: Double) {
        var weightKg: Double
        var weightPounds: Double
        var autoNormMl: Double
        var autoNormOz: Double
        
        let indexWeight = profile[0].gender == .girl ? 31.0 : 35.0
        
        if profile[0].unit == 0 {
            weightKg = weight
            weightPounds = Measurement(value: weightKg, unit: UnitMass.kilograms).converted(to: .pounds).value
        } else {
            weightKg = Measurement(value: weight, unit: UnitMass.pounds).converted(to: .kilograms).value
            weightPounds = weight
        }

        autoNormMl = 100*round(weightKg*indexWeight/100)
        autoNormOz = Measurement(value: autoNormMl, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value
        
        profile[0].weightKg = (weightKg * 10).rounded() / 10
        profile[0].weightPounds = (weightPounds * 10).rounded() / 10
        profile[0].autoNormMl = autoNormMl
        profile[0].customNormMl = autoNormMl
        profile[0].autoNormOz = autoNormOz
        profile[0].customNormOz = autoNormOz
    }
    
    func updateProfileGenderData(profile: [Profile], gender: Constants.Back.Types.Gender) {
        var autoNormMl: Double
        var autoNormOz: Double
        
        let indexWeight = gender == .girl ? 31.0 : 35.0
        let weightKg = profile[0].weightKg
        
        autoNormMl = 100*round(weightKg*indexWeight/100)
        autoNormOz = Measurement(value: autoNormMl, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value
                
        profile[0].genderName = gender.rawValue
        profile[0].autoNormMl = autoNormMl
        profile[0].customNormMl = autoNormMl
        profile[0].autoNormOz = autoNormOz
        profile[0].customNormOz = autoNormOz
    }
    
    func updateProfileUnitData(profile: [Profile], unit: Int) {
        profile[0].unit = unit
    }
    
    func updateProfileAutoCalcData(profile: [Profile], autoCalc: Bool) {
        profile[0].autoCalc = autoCalc
    }
    
    func updateProfileCustomNormData(profile: [Profile], customNorm: Double) {
        if profile[0].unit == 0 {
            profile[0].customNormMl = customNorm
            profile[0].customNormOz = Measurement(value: customNorm, unit: UnitVolume.milliliters).converted(to: .imperialFluidOunces).value
        } else {
            profile[0].customNormOz = customNorm
            profile[0].customNormMl = Measurement(value: customNorm, unit: UnitVolume.imperialFluidOunces).converted(to: .milliliters).value
        }
    }
}
