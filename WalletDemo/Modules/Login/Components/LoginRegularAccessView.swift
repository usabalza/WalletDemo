//
//  LoginRegularAccessView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct LoginRegularAccessView: View {
    @Bindable var viewModel: LoginViewModel
    var appStateManager: AppStateManager
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48)).foregroundColor(.accentColor)
                Text("Introduce tu PIN")
                    .font(.title2.bold())
                Text("Tu Wallet está protegida por encriptación local")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            
            HStack(spacing: 24) {
                ForEach(0..<4, id: \.self) { index in
                    Circle().fill(index < viewModel.pinInput.count ? Color.accentColor : Color(.systemGray4)).frame(width: 18, height: 18)
                }
            }
            .offset(x: viewModel.attemptsOffset)
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 18) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        appendDigit("\(number)")
                    } label: {
                        Text("\(number)").font(.title).foregroundColor(.primary).frame(maxWidth: .infinity, minHeight: 70).background(Color(.systemGray6)).clipShape(Circle())
                    }
                }
                
                // 👁️ BOTÓN DE ACCESO BIOMÉTRICO ORDINARIO RÁPIDO (HIG)
                Button {
                    if appStateManager.isBiometricsConfigured {
                        appStateManager.loginSuccess() // FaceID exitoso simulado instantáneo
                    }
                } label: {
                    Image(systemName: "faceid")
                        .font(.title).foregroundColor(appStateManager.isBiometricsConfigured ? .accentColor : .secondary.opacity(0.3))
                        .frame(maxWidth: .infinity, minHeight: 70)
                }
                .disabled(!appStateManager.isBiometricsConfigured)
                
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
        /*.onAppear {
            // HIG: Si tiene FaceID activo, gatillar el escaneo automático inmediatamente al entrar a la pantalla
            if appStateManager.isBiometricsConfigured {
                appStateManager.loginSuccess()
            }
        }*/
    }
    
    private func appendDigit(_ digit: String) {
        guard viewModel.pinInput.count < 4 else { return }
        viewModel.pinInput.append(digit)
        
        if viewModel.pinInput.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if viewModel.pinInput == appStateManager.savedPIN {
                    appStateManager.loginSuccess()
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    withAnimation(.default) { viewModel.attemptsOffset = 15 }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) { viewModel.attemptsOffset = 0 }
                    viewModel.pinInput = ""
                }
            }
        }
    }
}

