//
//  SelectAmountView.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import SwiftUI

struct SelectAmountView: View {
    @State private var selectedAmount = 0
    
    @State var model = WatchSessionManager.shared
    @Binding var isShowingModal: Bool
    
    @State var nameDrink: String
    @State var localizedNameDrink: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker(selection: $selectedAmount, label: Text(localizedNameDrink).font(.caption)) {
                ForEach(0 ..< getValuesPicker(unitValue: model.amountUnit).count, id: \.self) {
                    Text(self.getValuesPicker(unitValue: model.amountUnit)[$0])
                        .foregroundColor(.white)
                }
            }
            
            Button("Добавить") {
                let phoneWatchMessage = ["idOperation": UUID().uuidString, "nameDrink": nameDrink, "amountDrink": getValuesPicker(unitValue: model.amountUnit)[selectedAmount]]
                WatchSessionManager.shared.sendMessageToApp(phoneWatchMessage)
                isShowingModal = false
            }.font(.caption)
        }
    }
    
    func getValuesPicker(unitValue: String) -> Array<String> {
        let valuesMl = ["50", "100", "150", "200", "250", "300", "350", "400", "450", "500", "550", "600", "650", "700", "750", "800", "850", "900", "950", "1000", "1050", "1100", "1150", "1200", "1250", "1300", "1350", "1400", "1450", "1500", "1550", "1600", "1650", "1700", "1750", "1800", "1850", "1900", "1950", "2000"]
        let valuesOz = ["2", "4", "6", "8", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "30", "32", "34", "36", "38", "40", "42", "44", "46", "48", "50", "52", "54", "56", "58", "60", "62", "64", "66", "68"]
        var valuesPicker: Array<String>
        
        if unitValue == "250" {
            valuesPicker = valuesMl
        } else {
            valuesPicker = valuesOz
        }
        return valuesPicker
    }
}

#Preview {
    SelectAmountView(isShowingModal: .constant(false), nameDrink: "Water", localizedNameDrink: "Water")
}
