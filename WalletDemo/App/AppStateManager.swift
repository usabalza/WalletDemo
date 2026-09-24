//
//  AppStateManager.swift
//  StackProject
//
//  Created by Uziel Sabalza on 18/9/26.
//

import SwiftUI
import SwiftData

enum AppFlow {
    case onboarding
    case login
    case mainApp
}

@Observable
class AppStateManager {
    var currentFlow: AppFlow = .onboarding
    
    // 💾 CONTENEDOR DE BASE DE DATOS DE SWIFTDATA
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    // Llaves de respaldo de UserDefaults para configuraciones rápidas de hardware
    private let onboardingStorageKey = "hasCompletedOnboarding"
    
    // 🔑 CONSTANTE ÚNICA: Evita errores de dedo al escribir las llaves de UserDefaults
    private let pinStorageKey = "savedUserPIN"
    private let biometricsStorageKey = "isBiometricsConfigured"
    
    // Propiedades persistentes corregidas y unificadas
    
    /// Devuelve el usuario activo actual guardado en SwiftData
    var currentUser: UserSession? {
        guard let context = modelContext else { return nil }
        do {
            // Buscamos si existe algún usuario registrado en la base de datos
            let descriptor = FetchDescriptor<UserSession>()
            let users = try context.fetch(descriptor)
            return users.first // Retorna el perfil si existe
        } catch {
            print("❌ Error al consultar el usuario en SwiftData: \(error)")
            return nil
        }
    }
    
    
    var isBiometricsConfigured: Bool {
        get { UserDefaults.standard.bool(forKey: biometricsStorageKey) }
        set { UserDefaults.standard.set(newValue, forKey: biometricsStorageKey) }
    }
    
    var savedPIN: String? {
        get { UserDefaults.standard.string(forKey: pinStorageKey) }
        set { UserDefaults.standard.set(newValue, forKey: pinStorageKey) }
    }
    
    // MARK: - CONSTRUCTOR CORREGIDO Y BLINDADO
    init() {
        setupSwiftDataShared()
    }
    
    // MARK: - ACCIONES DE FLUJO
    
    // ⚙️ Inicializa el motor de base de datos relacional de Apple de forma segura
    @MainActor
        private func setupSwiftDataShared() {
            // En lugar de instanciar un ModelContainer manual invasivo,
            // compartimos de forma segura el almacenamiento global de la RAM de iOS 17+
            let container = SharedModelContainer.shared
            self.modelContext = ModelContext(container)
            
            // Una vez que el hardware está enlazado de forma segura, evaluamos el flujo
            verifyCurrentSessionFlow()
        }
    
    func verifyCurrentSessionFlow() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        // 🎯 CORRECCIÓN: Leemos usando exactamente la misma llave unificada
        let hasSavedPIN = UserDefaults.standard.string(forKey: "savedUserPIN") != nil
        
        if !hasCompletedOnboarding {
            self.currentFlow = .onboarding
        } else if hasSavedPIN {
            // Si el usuario ya completó el flujo y tiene PIN, va directo a la pantalla de bloqueo
            self.currentFlow = .login
        } else {
            // Caso de seguridad por si el proceso quedó incompleto
            self.currentFlow = .onboarding
        }
    }
    
    func navigateToLogin() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            UserDefaults.standard.set(true, forKey: onboardingStorageKey)
            currentFlow = .login
        }
    }
    
    func loginSuccess() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            UserDefaults.standard.set(true, forKey: onboardingStorageKey)
            currentFlow = .mainApp
        }
    }
    
    func logout() {
        withAnimation(.easeInOut) {
            // 🗑️ LIMPIEZA DE PRODUCCIÓN: Al cerrar sesión, eliminamos el usuario de SwiftData por seguridad
            if let context = modelContext, let user = currentUser {
                context.delete(user)
                try? context.save()
            }
            
            // Reseteamos las preferencias de hardware
            UserDefaults.standard.set(false, forKey: onboardingStorageKey)
            currentFlow = .onboarding
        }
    }
}
