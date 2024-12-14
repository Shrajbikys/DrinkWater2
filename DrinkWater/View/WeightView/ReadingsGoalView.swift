//
//  ReadingsGoalView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 17.10.2024.
//

import SwiftUI

struct ReadingsGoalView: View {
    @State var dataWeight: [DataWeight]
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    @State private var value: String = ""
    @State var pressedButton: String
    @State private var selectedSegment: Int = 0
    @Binding var isShowKeyboardView: Bool
    @State private var isPressedImpact = false
    let segments: Array<LocalizedStringKey> = ["Сбросить вес", "Набрать вес"]
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                HStack {
                    TextField("Введите цель", text: $value)
                        .allowsHitTesting(false)
                        .font(Constants.Design.Fonts.BodyTitle2Font)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .padding(.leading, 20)
                    Button(action: {
                        isPressedImpact.toggle()
                        if !value.isEmpty {
                            value.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.white)
                            .background(Color.red.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 20)
                    .sensoryFeedback(.selection, trigger: isPressedImpact)
                }
                HStack {
                    Picker("", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .onChange(of: selectedSegment) { _, newValue in
                        dataWeight.last!.weightGoalType = newValue
                    }
                }
                CustomKeyboard(input: $value, isShowKeyboardView: $isShowKeyboardView, pressedButton: pressedButton)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 30)
            .onAppear {
                selectedSegment = dataWeight.last?.weightGoalType ?? 0
            }
        }
    }
}

#Preview {
    ReadingsGoalView(dataWeight: [DataWeight(date: Date(), goal: 55.0, weight: 75.0, weightGoalType: 0, difference: 20)], pressedButton: "Goal", isShowKeyboardView: .constant(false))
}
