//
//  SettingsSection.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case account = "Cuenta"
    case security = "Seguridad"
    case legal = "Legal & Salida"
    
    var id: String { self.rawValue }
}

struct SettingsItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let destination: SettingsDestination
}
