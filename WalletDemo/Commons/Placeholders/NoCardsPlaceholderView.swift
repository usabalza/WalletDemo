//
//  NoCardsPlaceholderView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct NoCardsPlaceholderView: View {
    var onAddCardTapped: () -> Void // Callback que conectará con el Router para abrir el formulario
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
                // Efecto visual premium continuo y discreto de iOS 17+
                .symbolEffect(.pulse.byLayer, options: .repeating) 
            
            VStack(spacing: 6) {
                Text("Sin Tarjetas Activas")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Vincula una tarjeta física o genera una tarjeta virtual instantánea para comenzar a operar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: onAddCardTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar Primera Tarjeta")
                }
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.58, contentMode: .fit) // Mantiene la relación de aspecto oficial exacta de la tarjeta real
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
