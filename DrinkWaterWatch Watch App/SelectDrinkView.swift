//
//  SelectDrinkView.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import SwiftUI

struct SelectDrinkView: View {
    @State var model = WatchSessionManager.shared
    @Binding var isShowingModal: Bool
    
    private let imageNameDrink: Array<String> = ["Water", "Coffee", "Tea", "Milk", "Juice", "Soda", "Cocoa", "Smoothie", "Yogurt", "Beer", "NonalcoholicBeer", "Wine"]
    private let nameDrink: Array<LocalizedStringKey> = ["Water", "Coffee", "Tea", "Milk", "Juice", "Soda", "Cocoa", "Smoothie", "Yogurt", "Beer", "NonalcoholicBeer", "Wine"]
    
    var body: some View {
        NavigationView{
            List {
                ForEach(0..<nameDrink.count, id: \.self) { index in
                    NavigationLink(destination: SelectAmountView(model: model, isShowingModal: $isShowingModal, nameDrink: imageNameDrink[index], localizedNameDrink: nameDrink[index])) {
                        HStack(alignment: .center, spacing: 10) {
                            Image("\(imageNameDrink[index])")
                            Text(nameDrink[index]).font(.system(size: 16))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SelectDrinkView(isShowingModal: .constant(false))
}
