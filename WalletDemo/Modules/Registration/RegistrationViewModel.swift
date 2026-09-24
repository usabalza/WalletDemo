//
//  RegistrationViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import SwiftData

@Observable
class RegistrationViewModel {
    // Paso 1: Email
    var email: String = ""
    var confirmEmail: String = ""
    var acceptedTerms: Bool = false
    
    // Paso 2 y 4: OTP
    var codeLength = 6
    var emailOTP: String = ""
    var phoneOTP: String = ""
    var otpCode: String = ""
    let correctOTP: String = "111111"
    var isLoading = false
    var isOTPReady = false
    
    // Paso 3: Teléfono
    var selectedCountryCode: String = "+58"
    var selectedCountryFlag: String = "🇻🇪"
    var phoneNumber: String = ""
    
    // Paso 5: Contraseña
    var password = ""
    var confirmPassword = ""
    
    // Paso 6: Datos Personales
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var gender: String = "Masculino"
    var documentType: String = "DNI"
    var documentNumber: String = ""
    
    var countdownTimer = CustomTimerManager(durationInSeconds: 120)
    var isRegistrationComplete: Bool = false
    var errorMessage: String?
    
    // Listado simulado de códigos internacionales
    let countryCodes = [
        (code: "+58", flag: "🇻🇪", name: "Venezuela"),
        (code: "+34", flag: "🇪🇸", name: "España"),
        (code: "+1", flag: "🇺🇸", name: "EE.UU."),
        (code: "+52", flag: "🇲🇽", name: "México"),
        (code: "+54", flag: "🇦🇷", name: "Argentina"),
        (code: "+57", flag: "🇨🇴", name: "Colombia"),
        (code: "+591", flag: "🇧🇴", name: "Bolivia"),
        (code: "+593", flag: "🇪🇨", name: "Ecuador"),
        (code: "+51", flag: "🇵🇪", name: "Perú"),
        (code: "+56", flag: "🇨🇱", name: "Chile"),
        (code: "+595", flag: "🇵🇾", name: "Paraguay"),
        (code: "+598", flag: "🇺🇾", name: "Uruguay"),
        (code: "+55", flag: "🇧🇷", name: "Brasil")
        
    ]
    
    var isCodeComplete: Bool {
        otpCode.count == codeLength
    }
    
    var isEmailFormatValid: Bool {
        // Expresión regular estándar para validar correos estructurados correctamente
        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        
        // Intentamos realizar el macheo del patrón de texto
        if let _ = email.range(of: emailPattern, options: .regularExpression) {
            return true
        }
        return false
    }
    
    // Validación en tiempo real de los requisitos de la contraseña
    var passwordRequirements: PasswordRequirements {
        var req = PasswordRequirements()
        req.hasMinLength = password.count >= 8
        req.hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        req.hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        req.hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        req.hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-]", options: .regularExpression) != nil
        return req
    }
    
    var isEmailStepValid: Bool {
        let fieldsNotEmpty = !email.isEmpty && !confirmEmail.isEmpty
        let emailsMatch = email.lowercased() == confirmEmail.lowercased()
        
        return fieldsNotEmpty && emailsMatch && isEmailFormatValid && acceptedTerms
    }
    
    var isPhoneStepValid: Bool {
        phoneNumber.count >= 7 // Validación básica de longitud telefónica
    }
    
    // Validación del OTP
    
    func handleCodeChange(to newValue: String) {
        let filtered = String(newValue.filter { $0.isNumber }.prefix(codeLength))
        if otpCode != filtered {
            otpCode = filtered
        }
        
        if filtered.count == codeLength && !isLoading {
            Task { await verifyOTP() }
        }
    }
    
    func clearOTP() {
        self.otpCode = ""
    }
    
    func resendCode() {
        clearOTP()
        countdownTimer.start()
    }
    
    func verifyOTP() async {
        guard isCodeComplete && !isLoading else { return }
        isLoading = true
        
        try? await Task.sleep(for: .seconds(1))
        if otpCode == correctOTP {
            isOTPReady = true
        } else {
            print("Error")
            // showErrorMessage = true
        }
        clearOTP() // Simulación de error (vuelve a limpiar campos)
        
        isLoading = false
    }
    
    func completeRegistrationProcess() {
        // Aquí se dispararía la petición POST a tu API real con toda la data acumulada
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            self.isRegistrationComplete = true
        }
    }
    
    @MainActor
    func finalizeRegistration(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Simulamos el tiempo de espera de red (Latencia de API)
            try await Task.sleep(for: .seconds(1.5))
            
            // 2. Instanciamos el modelo de SwiftData con la data acumulada del Wizard
            let newUserSession = UserSession(
                // 🎯 REGLA DE ORO: Guardamos siempre en minúsculas y sin espacios
                firstName: self.firstName,
                lastName: self.lastName,
                email: self.email.trimmedAndLowercased(),
                phoneNumber: "\(self.selectedCountryCode)\(self.phoneNumber)",
                gender: self.gender,
                password: self.password,
                documentType: self.documentType,
                documentNumber: self.documentNumber,
                birthDate: self.birthDate.toShortString()
            )
            
            // 3. Insertamos el nuevo registro en la base de datos local SQLite de iOS
            context.insert(newUserSession)
            
            // 4. Forzamos el guardado inmediato en el disco
            try context.save()
            
            // 5. Activamos la bandera de éxito para levantar el Cover Animado
            withAnimation(.spring()) {
                self.isRegistrationComplete = true
            }
            
        } catch {
            self.errorMessage = "Error al guardar el perfil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
