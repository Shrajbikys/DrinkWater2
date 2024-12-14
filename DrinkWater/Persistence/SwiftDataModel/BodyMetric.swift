//
//  BodyMetric.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 11.12.2024.
//

import Foundation
import SwiftData

@Model
final class BodyMetric: Identifiable {
    var id: String = UUID().uuidString
    var date: Date = Date()
    var chestSize: Double = 0.0
    var waistSize: Double = 0.0
    var hipSize: Double = 0.0
    var differenceChestSize: Double = 0.0
    var differenceWaistSize: Double = 0.0
    var differenceHipSize: Double = 0.0
    
    init(date: Date = Date(), chestSize: Double = 0.0, waistSize: Double = 0.0, hipSize: Double = 0.0, differenceChestSize: Double = 0.0, differenceWaistSize: Double = 0.0, differenceHipSize: Double = 0.0) {
        self.id = UUID().uuidString
        self.date = date
        self.chestSize = chestSize
        self.waistSize = waistSize
        self.hipSize = hipSize
        self.differenceChestSize = differenceChestSize
        self.differenceWaistSize = differenceWaistSize
        self.differenceHipSize = differenceHipSize
    }
}
