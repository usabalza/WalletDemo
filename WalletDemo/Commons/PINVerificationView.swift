//
//  PINVerificationView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct PINVerificationView: View {
    @Binding var isPresented: Bool
    var onVerificationSuccess: () -> Void
    
    @State private var pinCode: String = ""
    @State private var attemptsOffset: CGFloat = 0 // Para animación de sacudida si falla
    private let maxDigits: Int = 4
    private let correctPIN: String = "1234" // Tu PIN precargado simulado
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Cabecera Informativa
            VStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.accentColor)
                
                Text("Introduce tu PIN de Seguridad")
                    .font(.title2.bold())
                
                Text("Autoriza esta transacción ingresando tus 4 dígitos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // 🔘 INDICADORES VISUALES DE PIN (Círculos)
            HStack(spacing: 24) {
                ForEach(0..<maxDigits, id: \.self) { index in
                    Circle()
                        .fill(index < pinCode.count ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 20, height: 20)
                        .scaleEffect(index < pinCode.count ? 1.15 : 1.0)
                        .animation(.spring(response: 0.2), value: pinCode.count)
                }
            }
            .offset(x: attemptsOffset) // Aplica la sacudida si el PIN es incorrecto
            
            Spacer()
            
            // BUTTON KEYPAD (Teclado Numérico Estilo iOS Nativo)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    keypadButton(text: "\(number)")
                }
                
                // Celda vacía izquierda o acción secundaria
                Spacer()
                
                keypadButton(text: "0")
                
                // Botón de borrar celda derecha
                Button {
                    deleteLastDigit()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 70)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancelar") { isPresented = false }
            }
        }
    }
    
    // Función auxiliar para construir botones del teclado numérico
    @ViewBuilder
    private func keypadButton(text: String) -> some View {
        Button {
            appendDigit(text)
        } label: {
            Text(text)
                .font(.system(.title, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, minHeight: 75)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
    
    // MARK: - LÓGICA DE CONTROL
    private func appendDigit(_ digit: String) {
        guard pinCode.count < maxDigits else { return }
        
        // Respuesta haptica leve por cada toque (HIG)
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        pinCode.append(digit)
        
        // Validar si completó los 4 dígitos
        if pinCode.count == maxDigits {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                verifyPIN()
            }
        }
    }
    
    private func deleteLastDigit() {
        if !pinCode.isEmpty {
            pinCode.removeLast()
        }
    }
    
    private func verifyPIN() {
        if pinCode == correctPIN {
            // Éxito: Notificación táctil de éxito y callback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            isPresented = false
            onVerificationSuccess()
        } else {
            // Error: Notificación táctil de error, animación de sacudida y reinicio
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            
            withAnimation(.default) {
                attemptsOffset = 15
            }
            // Efecto de rebote
            withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0)) {
                attemptsOffset = 0
            }
            pinCode = "" // Limpiar el campo
        }
    }
}
