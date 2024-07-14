//
//  SelectGenderView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 26.05.2024.
//  Copyright © 2024 Shrajbikys. All rights reserved.
//

import SwiftUI

struct SelectGenderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("BackgroundLS")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                VStack(spacing: 55) {
                    Text("Выберите ваш пол:")
                        .font(.title)
                        .bold()
                    HStack(spacing: 25) {
                        VStack(spacing: 13) {
                            NavigationLink {
                                AdditionalInfoView(gender: .girl)
                            } label: {
                                Image("girlButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120)
                            }
                            Text("Женский")
                        }
                        
                        VStack(spacing: 13) {
                            NavigationLink {
                                AdditionalInfoView(gender: .man)
                            } label: {
                                Image("boyButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120)
                            }
                            Text("Мужской")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SelectGenderView()
}
