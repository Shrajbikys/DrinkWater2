//
//  CustomKeyboard.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 13.10.2024.
//

import SwiftUI
import SwiftData

struct CustomKeyboard: View {
    @Environment(\.modelContext) private var modelContext
    @Query var profile: [Profile]
    @Query(sort: \DataWeight.date, order: .forward) var dataWeight: [DataWeight]
    
    var profileViewModel = ProfileViewModel()
    @Binding var input: String
    @Binding var weightGoalType: Int?
    @Binding var isShowKeyboardView: Bool
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    @State var pressedButton: String
    @State private var isPressedImpact = false
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(1..<10) { number in
                    Button(action: {
                        isPressedImpact.toggle()
                        addDigit(digit: String(number))
                    }) {
                        Text("\(number)")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .sensoryFeedback(.selection, trigger: isPressedImpact)
                }
                Button(action: {
                    isPressedImpact.toggle()
                    addDot()
                }) {
                    Text(".")
                        .font(.title)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                .sensoryFeedback(.selection, trigger: isPressedImpact)
                Button(action: {
                    isPressedImpact.toggle()
                    if input.count > 0 {
                        addDigit(digit: "0")
                    }
                }) {
                    Text("0")
                        .font(.title)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                .sensoryFeedback(.selection, trigger: isPressedImpact)
                Button(action: {
                    handleOK()
                    isPressedImpact.toggle()
                    if Double(input) ?? 0 > 0 {
                        if !dataWeight.isEmpty && dataWeight.last!.date.yearMonthDay == Date().yearMonthDay {
                            if pressedButton == "Weight" {
                                let newWeight = input.isEmpty ? 0 : Double(input)!
                                dataWeight.last!.weight = newWeight
                                DispatchQueue.main.async {
                                    profileViewModel.updateProfileWeightData(profile: profile, weight: newWeight)
                                }
                                if dataWeight.count > 1 {
                                    dataWeight.last!.difference = dataWeight.last!.weight - dataWeight[dataWeight.count - 2].weight
                                }
                            } else if pressedButton == "Goal" {
                                dataWeight.last!.goal = input.isEmpty ? 0 : Double(input)!
                                dataWeight.last!.weightGoalType = weightGoalType ?? 0
                            }
                        } else {
                            let dataWeightItem = DataWeight()
                            dataWeightItem.date = Date()
                            if pressedButton == "Weight" {
                                let newWeight = input.isEmpty ? 0 : Double(input)!
                                let lastGoal = dataWeight.last?.goal ?? 0
                                let lastWeight = dataWeight.last?.weight ?? newWeight
                                dataWeightItem.weight = newWeight
                                dataWeightItem.goal = lastGoal
                                dataWeightItem.difference = newWeight - lastWeight
                                DispatchQueue.main.async {
                                    profileViewModel.updateProfileWeightData(profile: profile, weight: newWeight)
                                }
                            } else if pressedButton == "Goal" {
                                dataWeightItem.weight = dataWeight.last?.weight ?? 0
                                dataWeightItem.goal = input.isEmpty ? 0 : Double(input)!
                                dataWeightItem.weightGoalType = weightGoalType ?? 0
                            }
                            modelContext.insert(dataWeightItem)
                        }
                    }
                    isShowKeyboardView = false
                }) {
                    Text("OK")
                        .font(.title)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(10)
                }
                .sensoryFeedback(.impact, trigger: isPressedImpact)
            }
        }
    }
    
    private func addDigit(digit: String) {
        if input.count < 4 && (input != "0" || digit != "0") {
            input.append(digit)
        }
    }
    
    private func addDot() {
        if !input.contains(".") && !input.isEmpty && input.count < 3 {
            input.append(".")
        }
    }
    
    private func handleOK() {
        if input.hasSuffix(".") {
            if input.count < 4 {
                input.append("0")
            } else {
                input.removeLast()
            }
        }
    }
}
