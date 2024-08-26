//
//  StoreManager.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 14.07.2024.
//

import Foundation
import Observation
import StoreKit

enum PurchaseError: Error {
    case pending, failedVerification, cancelled, productNotFound
}

@Observable
class PurchaseManager {
    private let userDefaultsManager = UserDefaultsManager.shared
    // Available Products
    private(set) var premium: [Product] = []
    
    // Purchased Products
    private(set) var purchasedPremium: [Product] = []
    private(set) var hasPremium: Bool = false
    private(set) var displayPrice: String = ""
    
    // Listen for transactions
    var transactionListener: Task<Void, Error>? = nil
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: Configure
    
    func configure() async throws {
        do {
            transactionListener = createTransactionTask()
            try await retrieveAllProducts()
            try await updateUserPurchases()
        } catch {
            throw error
        }
    }
    
    // MARK: StoreKit Code
    
    func retrieveAllProducts() async throws {
        do {
            let premIdentifier: [String] = ["com.alexander.l.DrinkWater.subscription.forever"]
            let products = try await Product.products(for: premIdentifier)
            displayPrice = products[0].displayPrice
            self.premium.append(products[0])
        } catch {
            print(error)
            throw error
        }
    }
    
    func hasPurchased() -> Bool {
        if hasPremium {
            return true
        }
        return userDefaultsManager.hasPremium
    }
    
    func purchasePremium() async throws -> Bool {
        guard let product = premium.first else {
            throw PurchaseError.productNotFound
        }
        
        return try await purchaseProduct(product)
    }
    
    func restorePurchases() async throws {
        do {
            try await AppStore.sync()
            try await updateUserPurchases()
        } catch {
            throw error
        }
    }
    
    // MARK: Private Functions
    
    private func purchaseProduct(_ product: Product) async throws -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let result):
                let verificationResult = try self.verifyPurchase(result)
                try await updateUserPurchases()
                await verificationResult.finish()
                
                return true
            case .userCancelled:
                print("Cancelled")
            case .pending:
                print("Needs approval")
            @unknown default:
                fatalError()
            }
            
            return false
        } catch {
            throw error
        }
    }
    
    private func verifyPurchase<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updateUserPurchases() async throws {
        for await entitlement in Transaction.currentEntitlements {
            do {
                let verifiedPurchase = try verifyPurchase(entitlement)
                
                self.hasPremium = true
                
                if let premium = premium.first(where: { $0.id == verifiedPurchase.productID }) {
                    purchasedPremium.append(premium)
                    userDefaultsManager.hasPremium = true
                } else {
                    print("Verified subscription couldn't be matched to fetched subscription.")
                }
            } catch {
                print("Failing silently: Possible unverified purchase.")
                throw error
            }
        }
    }
    
    private func createTransactionTask() -> Task<Void, Error> {
        return Task.detached {
            for await update in Transaction.updates {
                do {
                    let transaction = try self.verifyPurchase(update)
                    try await self.updateUserPurchases()
                    await transaction.finish()
                } catch {
                    print("Transaction didn't pass verification - ignoring purchase.")
                }
            }
        }
    }
}
