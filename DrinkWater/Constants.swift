//
//  Constants.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 31.05.2024.
//

import Foundation
import SwiftUI

struct Constants {
    
    struct Design {
        
        struct AppFont {
            
            static let BodyTitle3Font = Font.system(size: 40)
            static let BodyTitle2Font = Font.system(size: 33)
            static let BodyTitle1Font = Font.system(size: 30)
            static let BodyLargeFont = Font.system(size: 25)
            static let BodyMainFont = Font.system(size: 20)
            static let BodyMediumFont = Font.system(size: 17)
            static let BodySmallFont = Font.system(size: 15)
            static let BodyMiniFont = Font.system(size: 12)
            
            //        static let HeaderPageFont = Font.system(size: 30, weight: .semibold)
            //
            //        static let BodyLargeFont = Font.system(size: 17, weight: .semibold)
            //        static let BodyMainFont = Font.system(size: 15, weight: .regular)
            //        static let BodyMediumFont = Font.system(size: 13, weight: .regular)
            //        static let BodyMediumFontBold = Font.system(size: 13, weight: .medium)
            //        static let BodySmallFont = Font.system(size: 10, weight: .medium)
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case girl = "Женщина"
    case man = "Мужчина"
}
