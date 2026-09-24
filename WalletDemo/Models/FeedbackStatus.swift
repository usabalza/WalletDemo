//
//  FeedbackStatus.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

// 🚦 Enum para determinar el comportamiento de la pantalla
enum FeedbackStatus {
    case success
    case failure
}

struct SuccessVoucherItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    var color: Color = .primary
}

struct StatusFeedbackConfiguration {
    let status: FeedbackStatus // 👈 Éxito o Fallo
    let title: String
    let subtitle: String
    var systemIcon: String? = nil // Opcional: Si es nil, usará los iconos por defecto del sistema
    var buttonTitle: String = "Entendido"
    var voucherItems: [SuccessVoucherItem]? = nil 
    
    // 🎨 Propiedades calculadas automáticas basadas en las HIG si no se especifican íconos a mano
    var activeIcon: String {
        if let customIcon = systemIcon { return customIcon }
        return status == .success ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
    }
    
    var activeColor: Color {
        return status == .success ? .green : .red
    }
}
