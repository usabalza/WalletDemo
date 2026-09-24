//
//  SettingsViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

@Observable
class SettingsViewModel {
    
    var isVerifyingPINForPassword: Bool = false
    // Estado reactivo para el interruptor de Biometría
    var isBiometricsEnabled: Bool = false {
        didSet {
            // Aquí se guardaría la preferencia real en UserDefaults
            UserDefaults.standard.set(isBiometricsEnabled, forKey: "isBiometricsEnabled")
        }
    }
    
    init() {
        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
    }
    
    // Agrupación de ítems por sección para la List
    func items(for section: SettingsSection) -> [SettingsItem] {
        switch section {
        case .account:
            return [
                SettingsItem(title: "Datos de Usuario", subtitle: "Modifica tu información personal", iconName: "person.fill", iconColor: .blue, destination: .editProfile)
            ]
        case .security:
            return [
                SettingsItem(title: "Modificar PIN", subtitle: "Clave de acceso rápida de 4 dígitos", iconName: "lock.fill", iconColor: .green, destination: .changePIN),
                SettingsItem(title: "Modificar Contraseña", subtitle: "Requiere validación de PIN previa", iconName: "key.fill", iconColor: .yellow, destination: .changePassword)
            ]
        case .legal:
            return [
                SettingsItem(title: "Términos y Condiciones", subtitle: "Políticas de uso y privacidad", iconName: "doc.text.fill", iconColor: .gray, destination: .termsAndConditions),
                SettingsItem(title: "Acerca de mí", subtitle: "Conoce al desarrollador", iconName: "person.fill.questionmark", iconColor: .red, destination: .aboutMe)
            ]
        }
    }
}
