//
//  ActualBodyMetricsView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 10.12.2024.
//

import SwiftUI
import SwiftData

struct LastBodyMetricsView: View {
    @Query var profile: [Profile]
    
    @State var date: Date
    @State var unit: Int
    @State var chestSize: Double
    @State var waistSize: Double
    @State var hipSize: Double
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundViewColor
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват груди")
                        Spacer()
                        Text("\(unit == 0 ? chestSize.toStringCm : chestSize.toStringInches)")
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 1.0))
                    }
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват талии")
                        Spacer()
                        Text("\(unit == 0 ? waistSize.toStringCm : waistSize.toStringInches)")
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 1.0))
                    }
                    HStack {
                        Image(systemName: profile[0].gender == .girl ? "figure.stand.dress" : "figure.arms.open")
                        Text("Обхват бёдер")
                        Spacer()
                        Text("\(unit == 0 ? hipSize.toStringCm : hipSize.toStringInches)")
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 1.0))
                    }
                }
                .padding(.horizontal)
                .foregroundStyle(.white)
                .font(Constants.Design.Fonts.BodyMediumFont)
            }
            .navigationTitle("Последняя запись от \(date.formatDayMonthYear)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LastBodyMetricsView(date: Date(), unit: 0, chestSize: 90.0, waistSize: 60.0, hipSize: 90.0)
        .modelContainer(PreviewContainer.previewContainer)
}
