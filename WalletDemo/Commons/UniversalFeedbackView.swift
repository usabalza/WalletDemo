//
//  UniversalFeedbackView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct UniversalFeedbackView: View {
    let config: StatusFeedbackConfiguration
    var onDismiss: () -> Void
    
    // Estados para controlar las micro-animaciones al entrar
    @State private var animateIcon = false
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 1. ICONO ANIMADO (Su color y forma se adaptan automáticamente al estado)
            ZStack {
                Circle()
                    .fill(config.activeColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateIcon ? 1.0 : 0.4)
                    .opacity(animateIcon ? 1.0 : 0.0)
                
                Image(systemName: config.activeIcon)
                    .font(.system(size: 58))
                    .foregroundColor(config.activeColor)
                    .scaleEffect(animateIcon ? 1.0 : 0.2)
                    // Efecto elástico: rota a la derecha si es éxito, o vibra si es fallo
                    .rotationEffect(.degrees(config.status == .success ? (animateIcon ? 0 : -45) : 0))
            }
            // Animación de sacudida horizontal exclusiva si la operación es un fallo
            .offset(x: (config.status == .failure && !animateIcon) ? 12 : 0)
            
            // Textos Principales Dinámicos
            VStack(spacing: 8) {
                Text(config.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(config.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // 2. VOUCHER DIGITAL CONDICIONAL
            if let items = config.voucherItems, !items.isEmpty {
                VStack(spacing: 16) {
                    ForEach(items) { item in
                        HStack {
                            Text(item.label)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(item.value)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(item.color)
                                .lineLimit(1)
                        }
                        
                        if item.id != items.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .offset(y: animateContent ? 0 : 30)
                .opacity(animateContent ? 1.0 : 0.0)
            }
            
            Spacer()
            
            // 3. BOTÓN DE CIERRE ADAPTATIVO
            Button {
                onDismiss()
            } label: {
                Text(config.buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    // Si falla, el botón toma un color gris/secundario según las HIG para mitigar la frustración visual
                    .background(config.status == .success ? Color.accentColor : Color(.systemGray3))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Trigger de Retroalimentación Física de Hardware (HIG)
            let generator = UINotificationFeedbackGenerator()
            if config.status == .success {
                generator.notificationOccurred(.success)
            } else {
                generator.notificationOccurred(.error)
            }
            
            // Disparador de animaciones visuales
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                animateIcon = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.18)) {
                animateContent = true
            }
        }
    }
}
