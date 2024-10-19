//
//  ReadingsWeightView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 09.10.2024.
//

import SwiftUI
import SwiftData

struct ReadingsWeightView: View {
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    @State private var value: String = ""
    @State var pressedButton: String
    @Binding var isShowKeyboardView: Bool
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            VStack {
                HStack {
                    TextField("Введите вес", text: $value)
                        .allowsHitTesting(false)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .padding(.leading, 20)
                    Button(action: {
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
                }
                CustomKeyboard(input: $value, isShowKeyboardView: $isShowKeyboardView, pressedButton: pressedButton)
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    ReadingsWeightView(pressedButton: "Weight", isShowKeyboardView: .constant(false))
}
