//
//  P2PContactTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import SwiftData
import Foundation
@testable import WalletDemo

@Suite("Módulo de Contactos P2P - Persistencia y Favoritos")
struct P2PContactTests {
    
    // MARK: - ⚙️ HELPERS DE ENTORNO EN MEMORIA ISO
    
    /// Inicializa un contexto de SwiftData efímero en la memoria RAM aislado para cada test
    @MainActor
    private func createInMemoryContext() throws -> ModelContext {
        let schema = Schema([UserSession.self, PersistentCard.self, PersistentTransaction.self, PersistentContact.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // MARK: - 🧪 TESTS: OPERACIONES DE ESCRITURA Y NORMALIZACIÓN
    
    @Test("Insertar un contacto nuevo de forma asíncrona debe persistir los datos limpios en minúsculas")
    @MainActor
    func createAndPersistContactSuccessfully() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = P2PListViewModel()
        
        // Datos ingresados por el usuario con mayúsculas y espacios accidentales
        let rawName = "María Delgado"
        let rawWalletID = "  Maria_Delgado  "
        let rawEmail = "MARIA@email.com "
        
        // When (Llamada asíncrona que simula latencia de red bancaria)
        await viewModel.createAndPersistContact(
            context: context,
            name: rawName,
            walletID: rawWalletID,
            email: rawEmail
        )
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.contacts.count == 1)
        
        // 🔍 Auditoría en las tablas relacionales de SwiftData
        let descriptor = FetchDescriptor<PersistentContact>()
        let savedContacts = try context.fetch(descriptor)
        
        #expect(savedContacts.count == 1)
        let contact = savedContacts.first
        #expect(contact?.name == "María Delgado")
        
        // Validamos el requerimiento HIG de normalización automatizada estricta
        #expect(contact?.walletID == "maria_delgado", "El sistema falló al limpiar los espacios o ignorar las mayúsculas en el WalletID.")
        #expect(contact?.email == "maria@email.com", "El correo electrónico no se guardó normalizado en minúsculas.")
    }

    // MARK: - 🧪 TESTS: CONTROL DE ESTADOS DE HARDWARE
    
    @Test("Alternar el estado de favorito de un contacto debe impactar reactivamente la base de datos")
    @MainActor
    func toggleContactFavoriteStateInStorage() throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = P2PListViewModel()
        
        let newContact = PersistentContact(name: "Carlos Mendoza", walletID: "carlos_m", email: "carlos@email.com", isFavorite: false)
        context.insert(newContact)
        try? context.save()
        
        // Sincronizamos el arreglo de la interfaz
        viewModel.loadContacts(context: context)
        #expect(viewModel.contacts.first?.isFavorite == false)
        
        // When (El usuario presiona la estrella ⭐ en el LazyVStack)
        viewModel.toggleFavoriteInStorage(context: context, contact: newContact)
        
        // Then
        #expect(viewModel.contacts.first?.isFavorite == true, "La bandera de favorito no cambió en el arreglo mutable de la UI.")
        
        // Verificación cruzada en el almacenamiento físico SQLite
        let savedContacts = try context.fetch(FetchDescriptor<PersistentContact>())
        #expect(savedContacts.first?.isFavorite == true, "El cambio de favorito no persistió de forma permanente en el disco.")
    }

    // MARK: - 🧪 TESTS: INTEGRIDAD DE DATOS (ACCIONES DESTRUCTIVAS HIG)
    
    @Test("Eliminar un contacto desde el menú contextual debe borrar la fila físicamente del disco SQLite")
    @MainActor
    func deleteContactRemovesRowPermanentlyFromStorage() throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = P2PListViewModel()
        
        let contactToDelete = PersistentContact(name: "Ana Silva", walletID: "ana_s", email: "ana@email.com", isFavorite: true)
        context.insert(contactToDelete)
        try? context.save()
        
        viewModel.loadContacts(context: context)
        #expect(viewModel.contacts.count == 1)
        
        // When (El usuario ejecuta el borrado desde las acciones destructivas resguardadas)
        viewModel.deleteContactFromStorage(context: context, contact: contactToDelete)
        
        // Then
        #expect(viewModel.contacts.isEmpty, "El contacto no se removió del listado reactivo de la interfaz.")
        
        // 🔍 Auditoría de Integridad: La tabla de contactos en la base de datos local debe estar en cero
        let postDeleteFetch = try context.fetch(FetchDescriptor<PersistentContact>())
        #expect(postDeleteFetch.isEmpty, "🚨 ERROR DE SEGURIDAD: El registro sigue existiendo en el disco tras pulsar Eliminar.")
    }
}
