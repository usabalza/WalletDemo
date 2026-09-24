//
//  WalletTab.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import Foundation

enum WalletTab: Int, CaseIterable {
    case home = 0
    case qrOperations
    case p2p
    case settings
    
    var title: String {
        switch self {
        case .home: return "Inicio"
        case .qrOperations: return "QR"
        case .p2p: return "Contactos"
        case .settings: return "Ajustes"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "creditcard.fill"
        case .qrOperations: return "qrcode"
        case .p2p: return "person.2.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
