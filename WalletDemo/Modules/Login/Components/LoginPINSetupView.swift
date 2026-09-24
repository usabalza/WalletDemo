//
//  LoginPINSetupView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct LoginPINSetupView: View {
    @Bindable var viewModel: LoginViewModel
    var appStateManager: AppStateManager
    
    var isConfirming: Bool { viewModel.currentStep == .pinConfirmation }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: isConfirming ? "lock.rotation" : "lock.fill")
                    .font(.system(size: 44)).foregroundColor(.accentColor)
                
                Text(isConfirming ? "Confirma tu PIN" : "Crea tu PIN de Acceso")
                    .font(.title2.bold())
                Text(isConfirming ? "Vuelve a escribir los 4 dígitos para validar" : "Configura una contraseña rápida de 4 dígitos para proteger tu dinero")
                    .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            
            // Círculos de progreso
            HStack(spacing: 24) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.pinInput.count ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 18, height: 18)
                }
            }
            .offset(x: viewModel.attemptsOffset)
            
            Spacer()
            
            // Teclado Numérico Atómico
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 18) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        appendDigit("\(number)")
                    } label: {
                        Text("\(number)").font(.title).foregroundColor(.primary).frame(maxWidth: .infinity, minHeight: 70).background(Color(.systemGray6)).clipShape(Circle())
                    }
                }
                Spacer()
                Button {
                    appendDigit("0")
                } label: {
                    Text("0").font(.title).foregroundColor(.primary).frame(maxWidth: .infinity, minHeight: 70).background(Color(.systemGray6)).clipShape(Circle())
                }
                Button {
                    if !viewModel.pinInput.isEmpty {
                        viewModel.pinInput.removeLast()
                    }
                } label: {
                    Image(systemName: "delete.left.fill").font(.title2).foregroundColor(.secondary).frame(maxWidth: .infinity, minHeight: 70)
                }
            }
            .padding(.horizontal, 45).padding(.bottom, 20)
        }
    }
    
    private func appendDigit(_ digit: String) {
        guard viewModel.pinInput.count < 4 else { return }
        viewModel.pinInput.append(digit)
        
        if viewModel.pinInput.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if !isConfirming {
                    viewModel.temporaryPIN = viewModel.pinInput
                    viewModel.pinInput = ""
                    withAnimation { viewModel.currentStep = .pinConfirmation }
                } else {
                    if viewModel.pinInput == viewModel.temporaryPIN {
                        // Guardado exitoso definitivo del PIN creado
                        appStateManager.savedPIN = viewModel.pinInput
                        appStateManager.loginSuccess() // 🚀 Rompe el Login e ingresa a la App
                    } else {
                        // Error de coincidencia
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        withAnimation(.default) { viewModel.attemptsOffset = 15 }
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) { viewModel.attemptsOffset = 0 }
                        viewModel.pinInput = ""
                        withAnimation { viewModel.currentStep = .pinCreation } // Reinicia el paso
                    }
                }
            }
        }
    }
}
