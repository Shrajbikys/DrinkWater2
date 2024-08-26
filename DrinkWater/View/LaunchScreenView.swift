//
//  LaunchScreenView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.08.2024.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Image("BackgroundLS_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            VStack(spacing: 5) {
                Spacer()
                Text("Drink Water")
                    .font(Constants.Design.Fonts.BodyTitle2Font)
                    .foregroundStyle(.white)
                Text("Made with love")
                    .font(Constants.Design.Fonts.BodySmallFont)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 60)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    LaunchScreenView()
}
