//
//  LoginView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct LoginView: View {
    // 🔑 SOLUCIÓN CRÍTICA: Capturamos el manager real del entorno global
    @Environment(AppStateManager.self) private var appStateManager
    @State private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.currentStep {
            case .traditionalLogin:
                LoginTraditionalView(viewModel: viewModel)
            case .biometricsSetup:
                LoginBiometricsSetupView(viewModel: viewModel)
            case .pinCreation, .pinConfirmation:
                LoginPINSetupView(viewModel: viewModel, appStateManager: appStateManager)
            case .regularAccess:
                LoginRegularAccessView(viewModel: viewModel, appStateManager: appStateManager)
            }
        }
        .background(Color(.systemBackground))
        // 🎯 GATILLO DE ARRANQUE: Evaluamos la persistencia real del disco justo al aparecer en pantalla
        .onAppear {
            if appStateManager.savedPIN != nil {
                // Si el disco ya registra un PIN del pasado, forzamos el acceso diario directo
                viewModel.currentStep = .regularAccess
            } else {
                // Si no hay PIN, es una sesión limpia de instalación inicial
                viewModel.currentStep = .traditionalLogin
            }
        }
    }
}
