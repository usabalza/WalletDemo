//
//  ShimmerModifier.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3), // El destello brillante
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geometry.size.width * 2) // Asegura espacio suficiente para el desplazamiento
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                }
            )
            .mask(content) // El destello solo se dibuja sobre la forma del contenido original
            .onAppear {
                // Animación infinita y lineal para el efecto de barrido continuo
                withAnimation(
                    .linear(duration: 0.8)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
