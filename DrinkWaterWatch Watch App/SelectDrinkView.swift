//
//  SelectDrinkView.swift
//  DrinkWaterWatch Watch App
//
//  Created by Alexander Lyubimov on 23.07.2024.
//

import SwiftUI

struct SelectDrinkView: View {
    @EnvironmentObject var watchDrinkProvider: WatchDrinkDataProvider
    @State var model = WatchSessionManager.shared
    @Binding var isShowingModal: Bool
    
    var body: some View {
        NavigationView{
            List {
                ForEach(watchDrinkProvider.drinks.indices, id: \.self) { index in
                    NavigationLink(destination: SelectAmountView(model: model, isShowingModal: $isShowingModal, nameDrink: watchDrinkProvider.drinks[index].key, localizedNameDrink: watchDrinkProvider.drinks[index].name)) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(watchDrinkProvider.drinks[index].key)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            Text(watchDrinkProvider.drinks[index].name).font(.system(size: 16))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SelectDrinkView(isShowingModal: .constant(false))
        .environmentObject(WatchDrinkDataProvider())
}
