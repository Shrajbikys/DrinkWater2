//
//  NetworkMonitor.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 24.10.2024.
//

import Network
import SwiftUI

@Observable
class NetworkMonitor {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global(qos: .background)
    
    var isConnected: Bool = false
    
    init() {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        self.monitor.start(queue: queue)
    }
}
