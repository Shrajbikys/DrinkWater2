//
//  ContentView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 30.05.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var body: some View {
        Group {
            if !userDefaultsManager.isFirstSign {
                SelectGenderView()
            } else {
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
}
