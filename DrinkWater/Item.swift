//
//  Item.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 30.05.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
