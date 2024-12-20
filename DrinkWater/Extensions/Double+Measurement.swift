//
//  Double+Measurement.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 19.07.2024.
//

import Foundation
import SwiftUI

extension Double {
    
    var toStringMilli: String {
        let value = Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.milliliters).value.formatted(.number)
        let unit = Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.milliliters).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            return Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.milliliters).formatted(.measurement(width: .abbreviated, usage: .asProvided))
        } else {
            return "\(value) \(unit)"
        }
    }
    
    var toStringOunces: String {
        let value = Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.imperialFluidOunces).value.formatted(.number)
        let unit = Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.imperialFluidOunces).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            if Locale.preferredLanguages.first == "ru-RU" {
                return ("\(Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.imperialFluidOunces).value.formatted(.number)) унц")
            } else {
                return ("\(Measurement(value: self.rounded(.toNearestOrAwayFromZero), unit: UnitVolume.imperialFluidOunces).value.formatted(.number)) oz")
            }
        } else {
            return "\(value) \(unit)"
        }
    }
    
    var toStringKg: String {
        let value = Measurement(value: self, unit: UnitMass.kilograms).value.formatted(.number)
        let unit = Measurement(value: self, unit: UnitMass.kilograms).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            return Measurement(value: self, unit: UnitMass.kilograms).formatted(.measurement(width: .abbreviated, usage: .asProvided))
        } else {
            return "\(value) \(unit)"
        }
        
    }
    
    var toStringPounds: String {
        let value = Measurement(value: self, unit: UnitMass.pounds).value.formatted(.number)
        let unit = Measurement(value: self, unit: UnitMass.pounds).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            if Locale.preferredLanguages.first == "ru-RU" {
                return ("\(Measurement(value: self, unit: UnitMass.pounds).value.formatted(.number)) фн")
            } else {
                return ("\(Measurement(value: self, unit: UnitMass.pounds).value.formatted(.number)) lb")
            }
        } else {
            return "\(value) \(unit)"
        }
    }
    
    var toStringCm: String {
        let value = Measurement(value: self, unit: UnitLength.centimeters).value.formatted(.number)
        let unit = Measurement(value: self, unit: UnitLength.centimeters).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            return ("\(Measurement(value: self, unit: UnitLength.centimeters).formatted(.measurement(width: .abbreviated, usage: .asProvided)))")
        } else {
            return "\(value) \(unit)"
        }
    }
    
    var toStringInches: String {
        let value = Measurement(value: self, unit: UnitLength.inches).value.formatted(.number)
        let unit = Measurement(value: self, unit: UnitLength.inches).unit.symbol
        
        if Locale.current.identifier.localizedStandardContains("ru") {
            if Locale.preferredLanguages.first == "ru-RU" {
                return ("\(Measurement(value: self, unit: UnitLength.inches).value.formatted(.number)) дюйм")
            } else {
                return ("\(Measurement(value: self, unit: UnitLength.inches).value.formatted(.number)) inch")
            }
        } else {
            return "\(value) \(unit)"
        }
    }
}
