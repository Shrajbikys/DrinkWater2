//
//  LaunchScreenView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.08.2024.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var moveWaterDrop: Bool = false
    @State private var moveText: Bool = false
    
    private var titleText1 = "Drink Water"
    private var titleText2 = "Made from love"
    
    var body: some View {
        ZStack {
            Image("BackgroundLS")
            VStack {
                GeometryReader { geometry in
                    Image("WaterDrop")
                        .position(CGPoint(x: geometry.size.width / 2, y: moveWaterDrop ? geometry.size.height / 2 : -geometry.size.height + 850))
                        .animation(.easeInOut(duration: 3), value: moveWaterDrop)
                    HStack(spacing: 0) {
                        ForEach(Array(titleText1.enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                                .rotationEffect( moveText ? .degrees(0) : .degrees(360))
                                .opacity(moveText ? 1 : 0)
                                .offset(x: 0, y: moveText ? 100 : 0)
                                .animation(.easeOut(duration: 2).delay(Double(index) * 0.1), value: moveText)
                        }
                    }
                    .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 200))
                    HStack(spacing: 0) {
                        ForEach(Array(titleText2.enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .opacity(moveText ? 1 : 0)
                                .offset(x: 0, y: moveText ? 125 : 0)
                                .animation(.easeOut(duration: 2).delay(Double(index) * 0.1), value: moveText)
                        }
                    }
                    .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 200))
                }
            }
        }
        .onAppear {
            moveText = true
            moveWaterDrop = true
        }
    }
}

#Preview {
    LaunchScreenView()
}
