//
//  PersistentTransaction.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import Foundation
import SwiftData

@Model
class PersistentTransaction {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var amount: Double
    var isExpense: Bool
    var tagRaw: String
    
    var tag: TransactionTag {
        get { TransactionTag(rawValue: tagRaw) ?? .all }
        set { tagRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), amount: Double, isExpense: Bool, tag: TransactionTag) {
        self.id = id
        self.title = title
        self.date = date
        self.amount = amount
        self.isExpense = isExpense
        self.tagRaw = tag.rawValue
    }
}

struct ExpenseSummary: Identifiable, Hashable {
    let id = UUID()
    let monthName: String  // Ej: "May", "Jun", "Jul"
    let totalAmount: Double // Monto gastado
}

enum TransactionTag: String, Codable, Identifiable, CaseIterable {
    
    var id: String { self.rawValue }
    
    case all = "Todas"
    case qrPayment = "Pago QR"
    case qrRecharge = "Recarga QR"
    case p2pSent = "Envíos"
    case p2pReceived = "Recibidos"
}
