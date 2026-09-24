//
//  LoginViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import SwiftData

enum LoginStep {
    case biometricsSetup  // Configuración FaceID (Primera vez)
    case pinCreation      // Crear PIN (Primera vez)
    case pinConfirmation  // Confirmar PIN (Primera vez)
    case regularAccess    // Acceso común (Siguientes ingresos)
    case traditionalLogin
}

@Observable
class LoginViewModel {
    var currentStep: LoginStep = .traditionalLogin // Estado inicial por defecto
    var pinInput: String = ""
    var temporaryPIN: String = ""
    var attemptsOffset: CGFloat = 0
    
    var loginEmail = ""
    var loginPassword = ""
    var inlineErrorMessage: String?
    var isLoading: Bool = false
    
    var isTraditionalFormValid: Bool {
        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        let isEmailValid = loginEmail.range(of: emailPattern, options: .regularExpression) != nil
        return isEmailValid && loginPassword.count >= 8
    }
    
    // 🚀 MOTOR DE VALIDACIÓN ASÍNCRONO CONTRA SWIFTDATA
    @MainActor
    func authenticateUserWithAPI(context: ModelContext) async {
        self.isLoading = true
        self.inlineErrorMessage = nil
        
        do {
            // 1. Simulación de la latencia de red del servidor bancario
            try await Task.sleep(for: .seconds(1.3))
            
            // 🎯 SOLUCIÓN CRÍTICA: Normalizamos el texto en una constante local plana.
            // SwiftData NO soporta funciones de String (.lowercased()) dentro del predicado directo.
            let cleanedTargetEmail = loginEmail.trimmedAndLowercased()
            
            // 2. Consulta limpia en la base de datos de SwiftData
            let descriptor = FetchDescriptor<UserSession>(
                predicate: #Predicate<UserSession> { user in
                    // Comparamos dos constantes planas de tipo seguro (Garantiza éxito en SQLite)
                    user.email.localizedStandardContains(cleanedTargetEmail)
                }
            )
            
            let matchingUsers = try context.fetch(descriptor)
            
            // 3. Verificación de existencia del perfil
            if let foundUser = matchingUsers.first {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if foundUser.savedPIN != nil {
                        self.currentStep = .regularAccess // Va a la pantalla del PIN diario
                    } else {
                        self.currentStep = .biometricsSetup // Primer acceso: Configura FaceID
                    }
                }
            } else {
                // CASO FALLO: El correo electrónico no existe en el disco
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Las credenciales introducidas no coinciden con ningún usuario registrado en esta billetera."])
            }
            
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            withAnimation(.easeInOut) {
                self.inlineErrorMessage = error.localizedDescription
                self.loginPassword = "" // Limpiamos el campo por seguridad
            }
        }
        
        self.isLoading = false
    }

}

