//
//  ChangePasswordViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

@Observable
class ChangePasswordViewModel {
    var newPassword = ""
    var confirmNewPassword = ""
    
    var isLoading: Bool = false
    var isSuccessActive: Bool = false
    
    // Reutilizamos el motor de validación por Regex que diseñamos en el paso del Wizard
    var passwordRequirements: PasswordRequirements {
        var req = PasswordRequirements()
        req.hasMinLength = newPassword.count >= 8
        req.hasUppercase = newPassword.range(of: "[A-Z]", options: .regularExpression) != nil
        req.hasLowercase = newPassword.range(of: "[a-z]", options: .regularExpression) != nil
        req.hasNumber = newPassword.range(of: "[0-9]", options: .regularExpression) != nil
        req.hasSpecialChar = newPassword.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-]", options: .regularExpression) != nil
        return req
    }
    
    var isFormValid: Bool {
        passwordRequirements.isValid && !newPassword.isEmpty && newPassword == confirmNewPassword
    }
    
    @MainActor
    func updatePasswordInStorage(context: ModelContext, user: UserSession) async {
        self.isLoading = true
        
        // Simulación de latencia de red bancaria (HIG)
        try? await Task.sleep(for: .seconds(1.4))
        
        // Modificamos la clave real de SwiftData de la sesión activa
        user.password = self.newPassword
        try? context.save()
        
        withAnimation {
            self.isSuccessActive = true
        }
        
        self.isLoading = false
    }
}
