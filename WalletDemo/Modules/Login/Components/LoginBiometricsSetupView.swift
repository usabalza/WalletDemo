//
//  LoginBiometricsSetupView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct LoginBiometricsSetupView: View {
    var viewModel: LoginViewModel
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "faceid")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                //.symbolEffect(.bounce, options: .repeating) // Animación nativa de iOS 17
            
            VStack(spacing: 12) {
                Text("Activar Acceso Biométrico")
                    .font(.title2.bold())
                Text("Utiliza FaceID o TouchID para iniciar sesión de forma rápida y segura sin introducir tu contraseña.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                // Simulación de éxito de FaceID
                appStateManager.isBiometricsConfigured = true
                withAnimation { viewModel.currentStep = .pinCreation } // Siguiente paso
            } label: {
                Text("Habilitar FaceID / TouchID")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding().background(Color.accentColor).cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            Button("Quizás más tarde") {
                appStateManager.isBiometricsConfigured = false
                withAnimation { viewModel.currentStep = .pinCreation }
            }
            .font(.subheadline).foregroundColor(.secondary).padding(.bottom, 20)
        }
    }
}
