//
//  PurchaseView.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 10.06.2024.
//

import SwiftUI
import AppMetricaCore

struct PurchaseView: View {
    private let purchaseTitle1 = Constants.Back.Purchase.purchaseTitle1
    private let purchaseTitle2 = Constants.Back.Purchase.purchaseTitle2
    
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    @Binding var isPurchaseViewModal: Bool
    
    @State private var isNetworkAvailable = false
    let monitor = NWPathMonitor()
    
    private let backgroundViewColor: Color = Color(#colorLiteral(red: 0.3882352941, green: 0.6196078431, blue: 0.8509803922, alpha: 1))
    
    var body: some View {
        ZStack {
            backgroundViewColor
                .ignoresSafeArea()
            ScrollView {
                Image("LogoPro")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("Полный доступ ко всем функциям приложения Drink Water")
                    .font(Constants.Design.Fonts.BodyLargeFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack(alignment: .leading) {
                    ForEach(0..<purchaseTitle1.count, id: \.self) { index in
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.yellow)
                                .frame(width: 50)
                            VStack(alignment: .leading) {
                                Text(purchaseTitle1[index])
                                    .font(Constants.Design.Fonts.BodyMediumFont)
                                    .bold()
                                    .foregroundStyle(.yellow)
                                Text(purchaseTitle2[index])
                                    .font(Constants.Design.Fonts.BodySmallFont)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                ZStack {
                    Image("PurchaseBox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170)
                    VStack(spacing: 5) {
                        Text("Drink Water Pro")
                            .font(Constants.Design.Fonts.BodyMediumFont)
                            .foregroundStyle(.white)
                        Text("\(purchaseManager.displayPrice)")
                            .font(Constants.Design.Fonts.BodyLargeFont)
                            .bold()
                            .foregroundStyle(.white)
                        Text("Единоразово")
                            .font(Constants.Design.Fonts.BodyMiniFont)
                            .foregroundStyle(.white)
                        Button(action: {
                            joinPremium()
                            startNetworkMonitoring()
                        }, label: {
                            ZStack {
                                Image("PurchaseButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140)
                                Text("Продолжить")
                                    .foregroundStyle(.white)
                            }
                        })
                    }.padding(.top)
                }.padding(.bottom)
                VStack(spacing: 10) {
                    Text("Восстановить покупки")
                        .foregroundStyle(.link)
                        .onTapGesture {
                            restore()
                        }
                    Link("Условия использования", destination: URL(string: "https://telegra.ph/Terms--Conditions-02-17")!)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                    Link("Политика конфиденциальности", destination: URL(string: "https://telegra.ph/Privacy-Policy-02-17-9")!)
                        .font(Constants.Design.Fonts.BodyMediumFont)
                }
            }
        }
    }
    
    private func joinPremium() {
        Task {
            do {
                if try await purchaseManager.purchasePremium() {
                    withAnimation {
                        isPurchaseViewModal = false
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func restore() {
        Task {
            do {
                try await purchaseManager.restorePurchases()
            } catch {
                print(error)
            }
        }
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isNetworkAvailable = path.status == .satisfied
                reportEventIfNetworkAvailable()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func reportEventIfNetworkAvailable() {
        if isNetworkAvailable {
            AppMetrica.reportEvent(name: "PurchaseView", parameters: ["Press button": "JoinPremium"])
        } else {
            print("No network connection available. Cannot send event.")
        }
    }
}

#Preview {
    PurchaseView(isPurchaseViewModal: .constant(false))
        .environment(PurchaseManager())
}
