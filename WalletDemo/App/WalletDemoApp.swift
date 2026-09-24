//
//  WalletDemoApp.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import SwiftData

@main
struct WalletDemoApp: App {
    @State private var appStateManager = AppStateManager()
    var body: some Scene {
        WindowGroup {
            RootContentView()
            // Inyectamos el manejador en el Environment para que cualquier vista hija pueda usarlo
                .environment(appStateManager)
        }
        .modelContainer(SharedModelContainer.shared)
    }
}
