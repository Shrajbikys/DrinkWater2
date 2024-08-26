//
//  DrinkWaterWidgetBundle.swift
//  DrinkWaterWidget
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import WidgetKit
import SwiftUI

@main
struct DrinkWaterWidgetBundle: WidgetBundle {
    var body: some Widget {
        DrinkWaterWidgetSmall()
        DrinkWaterWidgetMedium()
        DrinkWaterWidgetLiveActivity()
    }
}
