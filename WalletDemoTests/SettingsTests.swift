//
//  SettingsTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import SwiftData
import Foundation
@testable import WalletDemo

@Suite("Módulo de Ajustes - Seguridad, Perfil y Preferencias de Hardware")
struct SettingsTests {
    
    // MARK: - ⚙️ HELPERS DE ENTORNO EN MEMORIA
    
    @MainActor
    private func createInMemoryContext() throws -> ModelContext {
        let schema = Schema([UserSession.self, PersistentCard.self, PersistentTransaction.self, PersistentContact.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
    
    @MainActor
    private func seedUser(context: ModelContext) -> UserSession {
        let user = UserSession(
            firstName: "Juan", lastName: "Perez", email: "juan@email.com",
            phoneNumber: "+584121234567", gender: "Masculino", password: "Admin123$",
            documentType: "DNI", documentNumber: "V12345678", birthDate: Date().toShortString()
        )
        user.savedPIN = "1234"
        user.password = "OldPassword2026!"
        context.insert(user)
        try? context.save()
        return user
    }

    // MARK: - 🧪 TESTS: PREFERENCIAS DE HARDWARE (USERDEFAULTS)
    
    @Test("Alternar el interruptor de Biometría debe persistir la preferencia en UserDefaults de forma inmediata")
    @MainActor
    func toggleBiometricsPersistsInUserDefaults() {
        // Given
        let viewModel = SettingsViewModel()
        
        // When (El usuario activa el Toggle de FaceID en la List nativa)
        viewModel.isBiometricsEnabled = true
        
        // Then
        #expect(UserDefaults.standard.bool(forKey: "isBiometricsEnabled") == true)
        
        // When (El usuario lo desactiva)
        viewModel.isBiometricsEnabled = false
        
        // Then
        #expect(UserDefaults.standard.bool(forKey: "isBiometricsEnabled") == false, "UserDefaults no se sincronizó con el estado del ViewModel.")
    }

    // MARK: - 🧪 TESTS: WIZARD DE CAMBIO DE PIN (AQUÍ REUTILIZAMOS LA LÓGICA SECUENCIAL)
    
    @Test("El asistente de modificación de PIN debe requerir validación estricta y avanzar paso a paso")
    @MainActor
    func sequentialPINChangeFlowValidation() {
        // Given (El PIN actual correcto guardado en el sistema simulado es "1234")
        let viewModel = ChangePINViewModel()
        #expect(viewModel.currentStep == .enterCurrent)
        
        // Escenario A: Ingresa PIN actual erróneo ➔ Debe sacudir y resetear
        viewModel.processDigit("9") { }
        viewModel.processDigit("9") { }
        viewModel.processDigit("9") { }
        viewModel.processDigit("9") { } // Envío automático del 4to dígito
        
        #expect(viewModel.currentStep == .enterCurrent, "El flujo avanzó de paso a pesar de introducir un PIN actual incorrecto.")
        #expect(viewModel.pinCode.isEmpty, "El campo de texto debió limpiarse inmediatamente tras el fallo.")
        
        // Escenario B: Ingresa PIN actual correcto ➔ Avanza a la creación del nuevo PIN
        viewModel.processDigit("1") { }
        viewModel.processDigit("2") { }
        viewModel.processDigit("3") { }
        viewModel.processDigit("4") { }
        
        #expect(viewModel.currentStep == .enterNew, "El asistente falló al mover el estado al paso .enterNew tras validar la clave correcta.")
        
        // Escenario C: Configura el nuevo PIN ("5555") ➔ Avanza a confirmación
        viewModel.processDigit("5") { }
        viewModel.processDigit("5") { }
        viewModel.processDigit("5") { }
        viewModel.processDigit("5") { }
        
        #expect(viewModel.currentStep == .confirmNew, "El flujo no avanzó a la confirmación de la nueva clave.")
    }

    // MARK: - 🧪 TESTS: MODIFICACIÓN MUTABLE DE DATOS EN SWIFTDATA (API SIMULADA)
    
    @Test("Guardar cambios del perfil debe sobreescribir de forma asíncrona la sesión en SwiftData")
    @MainActor
    func editProfileDataUpdatesUserSessionInStorage() async throws {
        // Given
        let context = try createInMemoryContext()
        let user = seedUser(context: context)
        let viewModel = ChangeProfileViewModel()
        
        // Precargamos los textos en los inputs de la pantalla (HIG)
        viewModel.loadCurrentUserData(user: user)
        #expect(viewModel.firstName == "Juan")
        
        // Modificamos los campos simulando la edición del usuario
        viewModel.firstName = "Juan Carlos"
        viewModel.documentNumber = "PASAPORTE999"
        
        // When (Pulsión del botón "Guardar Cambios" con latencia de red)
        await viewModel.updateProfileInStorage(context: context, user: user)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSuccessActive == true, "La bandera para levantar la UniversalFeedbackView de éxito no se encendió.")
        
        // 🔍 Auditoría Cruzada SQLite: Verificamos que el registro mutó permanentemente
        let fetchedUsers = try context.fetch(FetchDescriptor<UserSession>())
        #expect(fetchedUsers.first?.firstName == "Juan Carlos", "El nombre en disco no se sobreescribió.")
        #expect(fetchedUsers.first?.documentNumber == "PASAPORTE999")
    }

    // MARK: - 🧪 TESTS: CAMBIO DE CONTRASEÑA CON REGEX
    
    @Test("El formulario de cambio de clave debe rechazar contraseñas débiles o confirmaciones rotas")
    @MainActor
    func changePasswordValidationCriteria() async throws {
        // Given
        let context = try createInMemoryContext()
        let user = seedUser(context: context)
        let viewModel = ChangePasswordViewModel()
        
        // Caso A: Contraseña fuerte pero confirmación no coincide
        viewModel.newPassword = "NewWalletPass2026!"
        viewModel.confirmNewPassword = "DiferentePassword123!"
        #expect(viewModel.isFormValid == false, "El botón se habilitó a pesar de que las claves no coinciden.")
        
        // Caso B: Las contraseñas coinciden pero violan la seguridad por Regex (Sin carácter especial)
        viewModel.confirmNewPassword = "NewWalletPass2026"
        viewModel.newPassword = "NewWalletPass2026"
        #expect(viewModel.passwordRequirements.isValid == false)
        #expect(viewModel.isFormValid == false)
        
        // Caso C: Datos limpios y robustos ➔ Ejecución de persistencia asíncrona
        viewModel.newPassword = "SecurePass2026*"
        viewModel.confirmNewPassword = "SecurePass2026*"
        #expect(viewModel.isFormValid == true)
        
        await viewModel.updatePasswordInStorage(context: context, user: user)
        
        // Verificación en disco
        let fetchedUsers = try context.fetch(FetchDescriptor<UserSession>())
        #expect(fetchedUsers.first?.password == "SecurePass2026*", "La clave cifrada local no se actualizó en las tablas.")
        #expect(viewModel.isSuccessActive == true)
    }
}
