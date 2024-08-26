//
//  DrinkWaterComplicationsView.swift
//  DrinkWaterWatch ComplicationsExtension
//
//  Created by Alexander Lyubimov on 29.07.2024.
//

import SwiftUI

struct DrinkWaterComplicationsView: View {
    @Environment(\.widgetFamily) private var family
    
    var entry: ComplicationsEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplication(entry: entry)
            
        case .accessoryCorner:
            CornerComplication(entry: entry)
            
        case .accessoryInline:
            InlineComplication(entry: entry)
            
        case .accessoryRectangular:
            RectangularComplication(entry: entry)
            
        default:
            Image("AppIcon")
        }
    }
}
