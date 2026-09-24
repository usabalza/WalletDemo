//
//  RootContentView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

struct RootContentView: View {
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        // Envolvemos el árbol en un Group y aplicamos una animación de contenido nativa de iOS 17
        Group {
            switch appStateManager.currentFlow {
            case .onboarding:
                RegistrationView()
                    .id("onboarding_flow") // Forzamos un ID único para que SwiftUI destruya las demás vistas
                    .transition(.opacity)
                
            case .login:
                LoginView()
                    .id("login_flow") // Asegura que el contenedor de Login sea el único vivo en el render
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                
            case .mainApp:
                MainTabView()
                    .id("main_app_flow") // El Home solo se crea e inyecta cuando pasamos a .mainApp
                    .transition(.opacity)
            }
        }
        // Animación global de transiciones entre flujos del sistema
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: appStateManager.currentFlow)
        .onAppear {
            appStateManager.verifyCurrentSessionFlow()
        }
    }
}
