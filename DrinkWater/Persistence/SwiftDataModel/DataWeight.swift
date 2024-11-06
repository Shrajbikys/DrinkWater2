//
//  WeightData.swift
//  DataWeight
//
//  Created by Alexander Lyubimov on 13.10.2024.
//

import Foundation
import SwiftData

@Model
final class DataWeight: Identifiable {
    var id: String = UUID().uuidString
    var date: Date = Date()
    var goal: Double = 0
    var weight: Double = 0
    var weightGoalType: Int = 0
    var difference: Double = 0
    
    init(date: Date = Date(), goal: Double = 0, weight: Double = 0, weightGoalType: Int = 0, difference: Double = 0) {
        self.id = UUID().uuidString
        self.date = date
        self.goal = goal
        self.weight = weight
        self.weightGoalType = weightGoalType
        self.difference = difference
    }
}
