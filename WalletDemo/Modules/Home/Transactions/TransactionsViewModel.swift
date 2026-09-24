//
//  TransactionsViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import Observation

@Observable
class TransactionsViewModel {
    var allTransactions: [PersistentTransaction] = []
    var selectedTag: TransactionTag = .all
    
    init(transactions: [PersistentTransaction] = []) {
        self.allTransactions = transactions
    }
    
    // ⚙️ LÓGICA: Transacciones filtradas según el Tag seleccionado
    private var filteredTransactions: [PersistentTransaction] {
        if selectedTag == .all {
            return allTransactions
        }
        return allTransactions.filter { $0.tag == selectedTag }
    }
    
    // 🗂️ LÓGICA CRÍTICA: Agrupa por Día y ordena cronológicamente (Más reciente primero)
    var groupedTransactions: [(key: Date, value: [PersistentTransaction])] {
        let DictionaryGrouped = Dictionary(grouping: filteredTransactions) { transaction in
            // Normaliza la fecha para ignorar horas/minutos/segundos y agrupar solo por día entero
            Calendar.current.startOfDay(for: transaction.date)
        }
        // Ordena las fechas de forma descendente
        return DictionaryGrouped.sorted { $0.key > $1.key }
    }
}

