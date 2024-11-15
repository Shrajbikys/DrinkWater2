//
//  PurchaseViewWrapper.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 08.11.2024.
//

import SwiftUI

struct PurchaseViewWrapper: View {
    private var isPresented: Binding<Bool?>
    
    init(isPresented: Binding<Bool?>) {
        self.isPresented = isPresented
    }
    
    init(isPresented: Binding<Bool>) {
        self.isPresented = Binding<Bool?>(
            get: { isPresented.wrappedValue },
            set: { newValue in
                isPresented.wrappedValue = newValue ?? false
            }
        )
    }
    
    var body: some View {
        PurchaseView(isPurchaseViewModal: Binding(
            get: { isPresented.wrappedValue ?? false },
            set: { newValue in
                isPresented.wrappedValue = newValue
            }
        ))
    }
}

#Preview {
    PurchaseViewWrapper(isPresented: .constant(nil))
}
