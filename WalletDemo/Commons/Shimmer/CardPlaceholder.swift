//
//  CardPlaceholder.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct CardPlaceholder: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Fila Superior (Tipo de tarjeta e Icono)
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray4))
                    .frame(width: 80, height: 24)
                
                Spacer()
                
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 28, height: 28)
            }
            
            Spacer()
            
            // Fila Central (Monto / Balance)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray4))
                .frame(width: 160, height: 38)
            
            // Fila Inferior (Número de tarjeta y Expiración)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 50, height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 140, height: 16)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 50, height: 16)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.58, contentMode: .fit) // Relación de aspecto oficial
        .background(Color(.systemGray5)) // Fondo gris base del esqueleto
        .cornerRadius(10)
        .shimmer() // ✨ Activación del efecto Shimmer global en el componente
    }
}
