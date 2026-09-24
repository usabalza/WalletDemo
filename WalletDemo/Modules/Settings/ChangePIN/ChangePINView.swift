//
//  ChangePINView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct ChangePINView: View {
    @State private var viewModel = ChangePINViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 35) {
            Spacer()
            
            // 🔒 Cabecera Dinámica (Cambia de texto según el paso activo)
            VStack(spacing: 12) {
                Image(systemName: viewModel.currentStep == .enterCurrent ? "lock.shield.fill" : "lock.rotation")
                    .font(.system(size: 46))
                    .foregroundColor(.accentColor)
                    .contentTransition(.symbolEffect(.replace)) // Animación SF Symbols de iOS 17
                
                Text(viewModel.currentStep.title)
                    .font(.title2.bold())
                
                Text(viewModel.currentStep.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Círculos Indicadores de progreso de caracteres
            HStack(spacing: 24) {
                ForEach(0..<viewModel.maxDigits, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.pinCode.count ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 18, height: 18)
                        .scaleEffect(index < viewModel.pinCode.count ? 1.15 : 1.0)
                }
            }
            .offset(x: viewModel.attemptsOffset)
            
            Spacer()
            
            // Teclado Numérico Integrado Profesional
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 18) {
                ForEach(1...9, id: \.self) { number in
                    keypadButton(text: "\(number)")
                }
                
                Spacer() // Espacio vacío inferior izquierdo
                
                keypadButton(text: "0")
                
                Button {
                    viewModel.deleteLastDigit()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 70)
                }
            }
            .padding(.horizontal, 45)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(viewModel.currentStep != .enterCurrent) // Impide que rompan el wizard yendo atrás a la mitad
        // 🎯 CONTROL DE ÉXITO INTEGRADO
        .fullScreenCover(isPresented: $viewModel.isPINChangeSuccessful) {
            let successConfig = StatusFeedbackConfiguration(
                status: .success,
                title: "PIN Modificado",
                subtitle: "Tu nueva clave de acceso de 4 dígitos ha sido configurada correctamente. Utilízala a partir de tu próximo inicio de sesión bancario.",
                systemIcon: "lock.shield.fill",
                buttonTitle: "Volver a Ajustes"
            )
            UniversalFeedbackView(config: successConfig) {
                viewModel.isPINChangeSuccessful = false
                dismiss() // Cerramos por completo el módulo Push regresando al listado
            }
        }
    }
    
    @ViewBuilder
    private func keypadButton(text: String) -> some View {
        Button {
            viewModel.processDigit(text) {
                // Callback ejecutado sólo si se completa el paso final del validador con éxito
            }
        } label: {
            Text(text)
                .font(.system(.title, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, minHeight: 72)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
}
