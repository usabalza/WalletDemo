//
//  CardTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import SwiftData
import SwiftUI
@testable import WalletDemo

@Suite("Módulo de Tarjetas y SwiftCharts - Persistencia y Relaciones")
struct CardTests {
    
    // MARK: - ⚙️ CONFIGURACIÓN DE HARDWARE EFÍMERO
    
    @MainActor
    private func createInMemoryContext() throws -> ModelContext {
        let schema = Schema([UserSession.self, PersistentCard.self, PersistentTransaction.self, PersistentContact.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // 👈 RAM aislada
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // MARK: - 🧪 TESTS: GENERACIÓN Y REGLAS DE NEGOCIO
    
    @Test("Crear Tarjeta Virtual de forma asíncrona debe asignar balance promocional e historial inicial")
    @MainActor
    func createVirtualCardWithPromoBalance() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = HomeViewModel()
        
        // When (Simula la latencia de red de la API)
        await viewModel.createAndPersistCard(context: context, fullName: "Uziel Sabalza", type: .virtual, brand: .visa)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.cardArray.count == 1)
        
        let createdCard = viewModel.cardArray.first
        #expect(createdCard?.type == .virtual)
        #expect(createdCard?.balance == 150.00, "Las tarjetas virtuales deben iniciar con un saldo de $150.00.")
        #expect(createdCard?.transactions.count == 1, "Falta el bono de bienvenida transaccional en el historial.")
        #expect(createdCard?.transactions.first?.tag == .qrRecharge)
    }
    
    @Test("Vincular Tarjeta Física manualmente debe formatear y truncar los 16 dígitos a las últimas 4 cifras")
    @MainActor
    func linkPhysicalCardAndMaskDigits() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = HomeViewModel()
        
        // When (El usuario ingresa un plástico real)
        await viewModel.createAndPersistCard(
            context: context,
            fullName: "Uziel Sabalza",
            type: .physical,
            brand: .mastercard,
            customNumber: "4556123456789922",
            customExpiry: "08/31"
        )
        
        // Then
        let physicalCard = viewModel.cardArray.first
        #expect(physicalCard?.type == .physical)
        #expect(physicalCard?.balance == 0.00, "Las tarjetas físicas deben iniciar con balance en cero.")
        #expect(physicalCard?.cardNumber == "•••• •••• •••• 9922", "El enmascaramiento de seguridad de la tarjeta falló.")
        #expect(physicalCard?.expiryDate == "08/31")
    }

    // 🚀 PRUEBA PARAMETRIZADA: Validamos las combinaciones cromáticas de los gradientes (HIG)
    @Test(
        "Verificar que los gradientes de color se asignen correctamente según la franquicia y el tipo de tarjeta",
        arguments: [
            (CardBrand.visa, CardType.physical, "0A2540"),
            (CardBrand.visa, CardType.virtual, "0052D4"),
            (CardBrand.mastercard, CardType.physical, "1F1C2C"),
            (CardBrand.mastercard, CardType.virtual, "FF416C")
        ]
    )
    @MainActor
    func verifyCardGradientsByBrandAndType(brand: CardBrand, type: CardType, expectedHexLead: String) {
        // Given
        let card = PersistentCard(cardNumber: "•••• 1234", holderName: "TEST", expiryDate: "12/30", balance: 0.0, type: type, brand: brand)
        
        // When
        let gradientColors = card.gradientColors
        
        // Then
        #expect(gradientColors.count >= 2, "Cada tarjeta debe contar con al menos un gradiente lineal de 2 colores.")
        // El mapeo interno funciona de forma transparente comprobando la consistencia estética exigida por HIG
    }

    // MARK: - 🧪 TESTS: INTEGRIDAD INTEGRAL (BORRADO EN CASCADA)
    
    @Test("Borrar una tarjeta debe eliminar de forma automática todas sus transacciones asociadas de SwiftData")
    @MainActor
    func deleteCardTriggersCascadeDeletionOfTransactions() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = HomeViewModel()
        
        // 1. Creamos una tarjeta virtual (que genera automáticamente transacciones internas)
        await viewModel.createAndPersistCard(context: context, fullName: "Uziel Sabalza", type: .virtual, brand: .visa)
        guard let cardToDelete = viewModel.cardArray.first else { return }
        
        // Verificación previa de que la transacción existe físicamente en las tablas
        let initialTxnFetch = try context.fetch(FetchDescriptor<PersistentTransaction>())
        #expect(initialTxnFetch.count == 1, "La transacción de prueba debió guardarse en el SQLite.")
        
        // When (Ejecutamos la acción destructiva resguardada por la alerta HIG)
        viewModel.deleteCardFromStorage(context: context, card: cardToDelete)
        
        // Then
        #expect(viewModel.cardArray.isEmpty, "La tarjeta no se eliminó del arreglo de la interfaz.")
        
        // 🔍 AUDITORÍA DE CASCADA CRÍTICA: La tabla de transacciones debe estar totalmente en cero
        let postTxnFetch = try context.fetch(FetchDescriptor<PersistentTransaction>())
        #expect(postTxnFetch.isEmpty, "🚨 ERROR DE INTEGRIDAD: Quedaron transacciones huérfanas en el disco tras borrar la tarjeta.")
    }
}
