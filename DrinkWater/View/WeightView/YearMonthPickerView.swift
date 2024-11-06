//
//  YearMonthPickerView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 12.10.2024.
//

import SwiftUI
import AppMetricaCore

struct YearMonthPickerView: View {
    @Binding var selectedDate: Date
    @State private var isPressedImpact = false
    
    let months: [String] = Calendar.current.shortStandaloneMonthSymbols
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    var dateComponent = DateComponents()
                    dateComponent.year = -1
                    selectedDate = Calendar.current.date(byAdding: dateComponent, to: selectedDate)!
                    print(selectedDate)
                } label: {
                    Image(systemName: "chevron.left.square")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 24.0)
                        .padding(.trailing, 10)
                }
                Text(String(selectedDate.year))
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .transition(.move(edge: .trailing))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.0))
                    }
                Button {
                    var dateComponent = DateComponents()
                    dateComponent.year = 1
                    selectedDate = Calendar.current.date(byAdding: dateComponent, to: selectedDate)!
                    print(selectedDate)
                } label: {
                    Image(systemName: "chevron.right.square")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 24.0)
                        .padding(.leading, 10)
                }
                Spacer()
                Button {
                    selectedDate = Date()
                } label: {
                    Text("Текущий месяц")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.0))
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(months, id: \.self) { item in
                    Text(item.capitalized)
                        .font(.headline)
                        .frame(width: 70, height: 50)
                        .bold()
                        .foregroundStyle(.white)
                        .background(Color(white: 1, opacity: 0.1))
                        .background(item == selectedDate.monthShortStandalone ? Color(#colorLiteral(red: 0.9254901961, green: 0.7647058824, blue: 0.3176470588, alpha: 1)) : Color(white: 1, opacity: 0.1))
                        .cornerRadius(8)
                        .onTapGesture {
                            var dateComponent = DateComponents()
                            dateComponent.day = 1
                            dateComponent.month =  months.firstIndex(of: item)! + 1
                            dateComponent.year = Int(selectedDate.year)
                            selectedDate = Calendar.current.date(from: dateComponent)!
                            isPressedImpact.toggle()
                        }
                        .sensoryFeedback(.selection, trigger: isPressedImpact)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    YearMonthPickerView(selectedDate: .constant(Date()))
}
