//
//  P2PListViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

@Observable
class P2PListViewModel {
    var contacts: [PersistentContact] = [] // 🚨 Cambiado a modelo persistente real
    var isLoading: Bool = false
    
    // ⚙️ LÓGICA: Lee los contactos guardados en el disco SQLite ordenados alfabéticamente
    @MainActor
    func loadContacts(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<PersistentContact>(sortBy: [SortDescriptor(\.name)])
            self.contacts = try context.fetch(descriptor)
        } catch {
            print("❌ Error al leer los contactos de SwiftData: \(error.localizedDescription)")
        }
    }
    
    // ⚙️ LÓGICA: Alterna el estado de favoritos directamente en la base de datos
    @MainActor
    func toggleFavoriteInStorage(context: ModelContext, contact: PersistentContact) {
        contact.isFavorite.toggle()
        try? context.save() // Guarda el cambio inmediatamente en el disco
        loadContacts(context: context) // Refresca la UI
    }
    
    // ⚙️ LÓGICA: Elimina de forma permanente el registro de la base de datos (HIG)
    @MainActor
    func deleteContactFromStorage(context: ModelContext, contact: PersistentContact) {
        withAnimation(.easeInOut) {
            context.delete(contact)
            try? context.save()
            self.contacts.removeAll(where: { $0.id == contact.id })
        }
    }
    
    // ⚙️ LÓGICA: Inserta un nuevo amigo simulando tiempos de espera bancarios
    @MainActor
    func createAndPersistContact(context: ModelContext, name: String, walletID: String, email: String) async {
        self.isLoading = true
        
        // Simulación de latencia de red contra el servidor antes de guardar (HIG)
        try? await Task.sleep(for: .seconds(1.0))
        
        let cleanedWalletID = walletID.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newContact = PersistentContact(
            name: name,
            walletID: cleanedWalletID,
            email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        context.insert(newContact)
        try? context.save()
        
        loadContacts(context: context)
        self.isLoading = false
    }
}
