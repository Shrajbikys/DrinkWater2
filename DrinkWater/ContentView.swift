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
    @State private var showLaunchScreen = true
    
    var body: some View {
        Group {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            showLaunchScreen = false
                        }
                    }
            } else {
                if !userDefaultsManager.isFirstSign || !userDefaultsManager.isMigration {
                    SelectGenderView()
                } else {
                    MainView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
