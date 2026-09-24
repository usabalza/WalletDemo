//
//  SharedModelContainer.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftData

// 🎯 PATRÓN SINGLETON INDUSTRIAL PARA SWIFTDATA: Garantiza un único archivo SQLite activo
public enum SharedModelContainer {
    @MainActor
    public static let shared: ModelContainer = {
        let schema = Schema([
            UserSession.self,
            PersistentCard.self,
            PersistentTransaction.self,
            PersistentContact.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Fallo crítico al crear el contenedor único de SwiftData: \(error)")
        }
    }()
}
