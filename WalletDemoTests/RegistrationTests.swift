//
//  RegistrationTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import SwiftData
import Foundation
@testable import WalletDemo

// 📂 Agrupamos las pruebas en una Suite modular estructurada (Swift Testing Standard)
@Suite("Módulo de Registro - Validaciones y Persistencia Real")
struct RegistrationTests {
    
    // MARK: - ⚙️ CONFIGURACIÓN AUXILIAR (Helpers de Entorno)
    
    /// Genera un contexto de SwiftData en memoria RAM aislado para cada test (HIG)
    @MainActor
    private func createInMemoryContext() throws -> ModelContext {
        let schema = Schema([UserSession.self, PersistentCard.self, PersistentTransaction.self, PersistentContact.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // 👈 Datos efímeros
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // MARK: - 🧪 TESTS: VALIDACIONES DE CORREO (REGEX)
    
    @Test("Validar formato de Email correcto e indicaciones de paso")
    @MainActor
    func validateEmailStepWithValidData() {
        // Given
        let sut = RegistrationViewModel()
        
        // When
        sut.email = "uziel@sabalza.com"
        sut.confirmEmail = "uziel@sabalza.com"
        sut.acceptedTerms = true
        
        // Then (Usando la macro nativa #expect de Swift Testing)
        #expect(sut.isEmailFormatValid == true, "El Regex falló al validar una estructura internacional de correo correcta.")
        #expect(sut.isEmailStepValid == true, "El Wizard debió aprobar el paso uno con datos limpios.")
    }
    
    // 🚀 PRUEBA PARAMETRIZADA: Evaluamos múltiples correos inválidos de golpe en un solo Test
    @Test(
        "Detectar formatos de correo electrónico inválidos (Filtro Regex)",
        arguments: ["uziel@sabalza", "uziel.com", "@sabalza.com", "uziel@sabalza."]
    )
    @MainActor
    func detectInvalidEmailFormats(invalidEmail: String) {
        // Given
        let sut = RegistrationViewModel()
        
        // When
        sut.email = invalidEmail
        sut.confirmEmail = invalidEmail
        sut.acceptedTerms = true
        
        // Then
        #expect(sut.isEmailFormatValid == false, "El Regex falló al dejar pasar el correo corrupto: \(invalidEmail)")
    }
    
    @Test("Denegar avance si los correos no coinciden o faltan los Términos Legales")
    @MainActor
    func denyAdvanceWhenEmailsDoNotMatchOrTermsAreMissing() {
        let sut = RegistrationViewModel()
        
        // Caso A: Los correos no son idénticos
        sut.email = "uziel@sabalza.com"
        sut.confirmEmail = "otro@sabalza.com"
        sut.acceptedTerms = true
        #expect(sut.isEmailStepValid == false)
        
        // Caso B: Correos idénticos pero omitió leer el Sheet legal
        sut.confirmEmail = "uziel@sabalza.com"
        sut.acceptedTerms = false
        #expect(sut.isEmailStepValid == false, "El flujo avanzó saltándose las políticas de privacidad HIG.")
    }

    // MARK: - 🧪 TESTS: VALIDACIONES DE CONTRASEÑA
    
    @Test("Aprobar contraseñas fuertes que cumplan con la política bancaria por Regex")
    @MainActor
    func approveStrongPasswords() {
        let sut = RegistrationViewModel()
        sut.password = "WalletPass2026!"
        
        let req = sut.passwordRequirements
        
        #expect(req.hasMinLength)
        #expect(req.hasUppercase)
        #expect(req.hasLowercase)
        #expect(req.hasNumber)
        #expect(req.hasSpecialChar)
        #expect(req.isValid == true)
    }
    
    @Test("Rechazar contraseñas débiles que carezcan de caracteres especiales o números")
    @MainActor
    func rejectWeakPasswords() {
        let sut = RegistrationViewModel()
        
        sut.password = "walletpass" // Falta todo
        #expect(sut.passwordRequirements.isValid == false)
        
        sut.password = "WalletPass2026" // Falta carácter especial
        #expect(sut.passwordRequirements.isValid == false)
    }

    // MARK: - 🧪 TESTS: PERSISTENCIA ASÍNCRONA EN SWIFTDATA (API SIMULADA)
    
    @Test("Finalizar alta de usuario guardando el perfil de forma real en disco SQLite")
    @MainActor
    func finalizeRegistrationSuccessfully() async throws {
        // Given (Inicializamos SUT y el hardware en memoria aislado)
        let sut = RegistrationViewModel()
        let context = try createInMemoryContext()
        
        sut.email = "uziel@sabalza.com"
        sut.firstName = "Uziel"
        sut.lastName = "Sabalza"
        sut.selectedCountryCode = "+58"
        sut.phoneNumber = "4121234567"
        sut.gender = "Masculino"
        sut.documentType = "DNI"
        sut.documentNumber = "V12345678"
        
        // When (Llamada asíncrona concurrente que simula la red del servidor)
        await sut.finalizeRegistration(context: context)
        
        // Then
        #expect(sut.isRegistrationComplete == true, "La bandera para levantar el UniversalFeedbackView no se encendió.")
        #expect(sut.errorMessage == nil)
        
        // 🔍 Auditoría Relacional: Verificamos que la fila existe físicamente en las tablas
        let descriptor = FetchDescriptor<UserSession>()
        let savedUsers = try context.fetch(descriptor)
        
        #expect(savedUsers.count == 1, "Debería haber exactamente 1 registro persistido.")
        #expect(savedUsers.first?.firstName == "Uziel")
        // Verificamos el requerimiento HIG de normalización automatizada en minúsculas
        #expect(savedUsers.first?.email == "uziel@sabalza.com", "El email se guardó sin limpiar espacios o ignorar mayúsculas.")
    }
}
