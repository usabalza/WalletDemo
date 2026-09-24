//
//  PersistentCard.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import SwiftData

@Model
class PersistentCard {
    @Attribute(.unique) var id: UUID
    var cardNumber: String
    var holderName: String
    var expiryDate: String
    var balance: Double
    var cardTypeRaw: String // Almacena el enum como String en SQLite
    var cardBrandRaw: String
    
    // 🗂️ RELACIÓN EN CASCADA: Si borras la tarjeta, se eliminan sus movimientos del disco (HIG)
    @Relationship(deleteRule: .cascade) var transactions: [PersistentTransaction] = []
    
    // Propiedades computadas para interactuar limpiamente con tus Enums previos
    var type: CardType {
        get { CardType(rawValue: cardTypeRaw) ?? .physical }
        set { cardTypeRaw = newValue.rawValue }
    }
    
    var brand: CardBrand {
        get { CardBrand(rawValue: cardBrandRaw) ?? .visa }
        set { cardBrandRaw = newValue.rawValue }
    }
    
    // Mapeo automático de los 4 gradientes según la combinación exclusiva
    var gradientColors: [Color] {
        switch (brand, type) {
        case (.visa, .physical): return [Color(hex: "0A2540"), Color(hex: "1A3A5F")]
        case (.visa, .virtual): return [Color(hex: "0052D4"), Color(hex: "4364F7"), Color(hex: "6FB1FC")]
        case (.mastercard, .physical): return [Color(hex: "1F1C2C"), Color(hex: "4D3C5C")]
        case (.mastercard, .virtual): return [Color(hex: "FF416C"), Color(hex: "FF4B2B")]
        }
    }
    
    init(id: UUID = UUID(), cardNumber: String, holderName: String, expiryDate: String, balance: Double, type: CardType, brand: CardBrand) {
        self.id = id
        self.cardNumber = cardNumber
        self.holderName = holderName
        self.expiryDate = expiryDate
        self.balance = balance
        self.cardTypeRaw = type.rawValue
        self.cardBrandRaw = brand.rawValue
    }
}

struct CardAction {
    var name: String
    var icon: String
    var action: () -> Void
}

enum CardBrand: String, Codable {
    case visa = "VISA"
    case mastercard = "MasterCard"
}

enum CardType: String, Codable {
    case virtual
    case physical
}
