//
//  HomeViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import Observation
import SwiftData

@Observable
class HomeViewModel {
    var cardArray: [PersistentCard] = []
    
    var weeklyExpenses: [ExpenseSummary] {
        [
            ExpenseSummary(monthName: "Ene", totalAmount: 420.50),
            ExpenseSummary(monthName: "Feb", totalAmount: 310.00),
            ExpenseSummary(monthName: "Mar", totalAmount: 680.40),
            ExpenseSummary(monthName: "Abr", totalAmount: 215.10),
            ExpenseSummary(monthName: "May", totalAmount: 530.00),
            ExpenseSummary(monthName: "Jun", totalAmount: 490.75)
        ]
    }
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var addedCardWithSuccess: Bool = false
    
    @MainActor
    func loadWalletData(context: ModelContext) async {
        self.isLoading = true
        
        do {
            // Consulta real a las tablas SQLite ordenando las tarjetas por número o fecha
            let descriptor = FetchDescriptor<PersistentCard>(sortBy: [SortDescriptor(\.cardNumber)])
            let fetchedCards = try context.fetch(descriptor)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.cardArray = fetchedCards
            }
        } catch {
            self.errorMessage = "Fallo al leer las tarjetas del disco: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    // 🚀 LÓGICA DE INYECCIÓN ASÍNCRONA REAL EN DISCO (Simula API)
    @MainActor
    func createAndPersistCard(context: ModelContext, fullName: String, type: CardType, brand: CardBrand, customNumber: String? = nil, customExpiry: String? = nil) async {
        self.isLoading = true
        
        // Simulación de latencia de red contra el servidor (HIG)
        try? await Task.sleep(for: .seconds(1.2))
        
        let cardNumber: String
        let expiryDate: String
        
        if type == .virtual {
            cardNumber = "•••• •••• •••• \(Int.random(in: 1000...9999))"
            let currentYear = Calendar.current.component(.year, from: Date()) % 100
            expiryDate = String(format: "%02d/%02d", Int.random(in: 1...12), currentYear + 5)
        } else {
            let rawNumber = customNumber ?? "0000000000000000"
            cardNumber = "•••• •••• •••• \(rawNumber.suffix(4))"
            expiryDate = customExpiry ?? "12/30"
        }
        
        // Instanciamos el objeto con el esquema nativo de SwiftData
        let newCard = PersistentCard(
            cardNumber: cardNumber,
            holderName: fullName,
            expiryDate: expiryDate,
            balance: type == .virtual ? 150.00 : 0.00,
            type: type,
            brand: brand
        )
        
        // Inyectamos transacciones iniciales reales vinculadas de prueba si la tarjeta es virtual
        if type == .virtual {
            let welcomeTxn = PersistentTransaction(title: "Bono de bienvenida", amount: 150.00, isExpense: false, tag: .qrRecharge)
            newCard.transactions.append(welcomeTxn)
        }
        
        // 💾 Persistencia inmediata en base de datos SQLite
        context.insert(newCard)
        try? context.save()
        self.addedCardWithSuccess = true
        
        // Recargamos el estado de la UI reactivamente
        await loadWalletData(context: context)
        self.isLoading = false
        
    }
    
    @MainActor
    func deleteCardFromStorage(context: ModelContext, card: PersistentCard) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            // Remueve el objeto del disco y elimina sus transacciones por cascada
            context.delete(card)
            try? context.save()
            
            // Sincronizamos el arreglo local de la UI
            self.cardArray.removeAll(where: { $0.id == card.id })
        }
    }
}
