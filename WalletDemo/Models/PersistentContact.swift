//
//  PersistentContact.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import Foundation
import SwiftData

// MARK: - MODELO DE CONTACTO

@Model
class PersistentContact {
    @Attribute(.unique) var id: UUID
    var name: String
    var walletID: String
    var email: String
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, walletID: String, email: String, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.walletID = walletID
        self.email = email
        self.isFavorite = isFavorite
    }
}
