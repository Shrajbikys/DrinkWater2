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
    
    func createProfileForTheFirstLogin(modelContext: ModelContext, gender: Gender, weight: Double, unit: Int) {
        var weightKg: Double
        var weightPounds: Double
        var autoNormMl: Double
        var autoNormOz: Double
        
        let constWeightOzMl = 29.5735
        let constWeightPoundsKg = 2.20462
        
        let indexWeight = gender == .girl ? 31.0 : 35.0

        if unit == 0 {
            weightKg = weight
            weightPounds = weight*constWeightPoundsKg
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = autoNormMl/constWeightOzMl
        } else {
            weightKg = weight/constWeightPoundsKg
            weightPounds = weight
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = (weightKg*indexWeight)/constWeightOzMl
        }
        
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
        
        let constWeightOzMl = 29.5735
        let constWeightPoundsKg = 2.20462
        
        let indexWeight = profile[0].gender == .girl ? 31.0 : 35.0
        
        if profile[0].unit == 0 {
            weightKg = weight
            weightPounds = weight*constWeightPoundsKg
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = autoNormMl/constWeightOzMl
        } else {
            weightKg = weight/constWeightPoundsKg
            weightPounds = weight
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = (weightKg*indexWeight)/constWeightOzMl
        }
        
        profile[0].weightKg = weight
        profile[0].weightPounds = weightPounds
        profile[0].autoNormMl = autoNormMl
        profile[0].autoNormOz = autoNormOz
    }
    
    func updateProfileGenderData(profile: [Profile], gender: Gender) {
        var weightKg: Double
        var weightPounds: Double
        var autoNormMl: Double
        var autoNormOz: Double
        
        let constWeightOzMl = 29.5735
        let constWeightPoundsKg = 2.20462
        
        let indexWeight = gender == .girl ? 31.0 : 35.0
        let weight = profile[0].weightKg
        
        if profile[0].unit == 0 {
            weightKg = weight
            weightPounds = weight*constWeightPoundsKg
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = autoNormMl/constWeightOzMl
        } else {
            weightKg = weight/constWeightPoundsKg
            weightPounds = weight
            autoNormMl = 100*round(weightKg*indexWeight/100)
            autoNormOz = (weightKg*indexWeight)/constWeightOzMl
        }
        
        profile[0].genderName = gender.rawValue
        profile[0].weightKg = weight
        profile[0].weightPounds = weightPounds
        profile[0].autoNormMl = autoNormMl
        profile[0].autoNormOz = autoNormOz
    }
    
    func updateProfileUnitData(profile: [Profile], unit: Int) {
        profile[0].unit = unit
    }
    
    func updateProfileAutoCalcData(profile: [Profile], autoCalc: Bool) {
        profile[0].autoCalc = autoCalc
    }
    
    func updateProfileCustomNormData(profile: [Profile], customNorm: Double) {
        let constWeightOzMl = 29.5735
        
        if profile[0].unit == 0 {
            profile[0].customNormMl = customNorm
            profile[0].customNormOz = (customNorm/constWeightOzMl).rounded()
        } else {
            profile[0].customNormOz = customNorm
            profile[0].customNormMl = (customNorm*constWeightOzMl).rounded()
        }
    }
}
