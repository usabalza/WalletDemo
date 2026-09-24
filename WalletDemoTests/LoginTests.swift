//
//  LoginTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import SwiftData
import Foundation
@testable import WalletDemo

@Suite("Módulo de Autenticación y Login - Validaciones Reales")
struct LoginTests {
    
    // MARK: - ⚙️ HELPERS DE ENTORNO EN MEMORIA
    
    /// Inicializa un contexto de SwiftData efímero en la memoria RAM aislado para cada test
    @MainActor
    private func createInMemoryContext() throws -> ModelContext {
        let schema = Schema([UserSession.self, PersistentCard.self, PersistentTransaction.self, PersistentContact.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
    
    /// Pre-carga un usuario de prueba en el contexto SQLite efímero
    @MainActor
    private func seedUser(context: ModelContext, email: String, hasPIN: Bool) -> UserSession {
        let user = UserSession(
            firstName: "Uziel",
            lastName: "Sabalza",
            email: email,
            phoneNumber: "+584121234567",
            gender: "Masculino",
            password: "Admin123$",
            documentType: "DNI",
            documentNumber: "V12345678",
            birthDate: Date().toShortString()
        )
        if hasPIN {
            user.savedPIN = "1234"
        }
        context.insert(user)
        try? context.save()
        return user
    }

    // MARK: - 🧪 TESTS: VALIDACIONES DE FORMULARIO TRADICIONAL
    
    @Test("Validar habilitación de botón de Login según consistencia de formatos")
    @MainActor
    func validateTraditionalFormRequirements() {
        let viewModel = LoginViewModel()
        
        // Caso inicial vacío: Inválido
        #expect(viewModel.isTraditionalFormValid == false)
        
        // Correo correcto pero contraseña muy corta (HIG: botón deshabilitado preventivo)
        viewModel.loginEmail = "uziel@sabalza.com"
        viewModel.loginPassword = "123"
        #expect(viewModel.isTraditionalFormValid == false)
        
        // Formato correcto: Válido
        viewModel.loginPassword = "WalletPassword2026"
        #expect(viewModel.isTraditionalFormValid == true)
    }

    // MARK: - 🧪 TESTS: AUTENTICACIÓN ASÍNCRONA Y ENRUTAMIENTO (SIMULACIÓN DE API)
    
    @Test("Autenticar usuario existente con PIN configurado debe enrutarse a acceso regular diario")
    @MainActor
    func authenticateSuccessfulWithExistingPIN() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = LoginViewModel()
        let testEmail = "uziel@sabalza.com"
        
        // Pre-cargamos un usuario que ya tiene un PIN creado en el pasado
        let _ = seedUser(context: context, email: testEmail, hasPIN: true)
        
        viewModel.loginEmail = testEmail
        viewModel.loginPassword = "WalletPassword2026"
        
        // When (Llamada asíncrona concurrente que evalúa el Predicado SQLite)
        await viewModel.authenticateUserWithAPI(context: context)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.inlineErrorMessage == nil)
        #expect(viewModel.currentStep == .regularAccess, "El flujo debió saltar a .regularAccess para pedir el PIN diario.")
    }
    
    @Test("Autenticar usuario recién registrado sin PIN debe enrutarse al enrolamiento de FaceID")
    @MainActor
    func authenticateSuccessfulWithoutPIN() async throws {
        // Given
        let context = try createInMemoryContext()
        let viewModel = LoginViewModel()
        let testEmail = "nuevo@sabalza.com"
        
        // Pre-cargamos un usuario limpio (Sin PIN establecido)
        let _ = seedUser(context: context, email: testEmail, hasPIN: false)
        
        viewModel.loginEmail = testEmail
        viewModel.loginPassword = "WalletPassword2026"
        
        // When
        await viewModel.authenticateUserWithAPI(context: context)
        
        // Then
        #expect(viewModel.inlineErrorMessage == nil)
        #expect(viewModel.currentStep == .biometricsSetup, "Un usuario sin PIN debe configurar FaceID (.biometricsSetup) en su primer ingreso.")
    }
    
    @Test("Intentar loguear con un correo no registrado debe lanzar error inline mitigando frustración visual")
    @MainActor
    func authenticateFailsWithUnregisteredUser() async throws {
        // Given (Base de datos vacía sin usuarios)
        let context = try createInMemoryContext()
        let viewModel = LoginViewModel()
        
        viewModel.loginEmail = "no_existo@sabalza.com"
        viewModel.loginPassword = "WalletPassword2026"
        
        // When
        await viewModel.authenticateUserWithAPI(context: context)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.inlineErrorMessage != nil, "El ViewModel debió capturar el fallo e inyectar un mensaje de error legible para el usuario.")
        #expect(viewModel.loginPassword.isEmpty, "La contraseña debió limpiarse por seguridad ante un intento fallido.")
        #expect(viewModel.currentStep == .traditionalLogin, "La app no debió moverse del login tradicional ante un fallo.")
    }
}
