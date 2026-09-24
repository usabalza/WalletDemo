//
//  NoTransactionsPlaceholderView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct NoTransactionsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Contenedor circular suave para el icono conforme a las HIG
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "banknote")
                        .font(.title3)
                        .foregroundColor(.secondary)
                )
            
            VStack(spacing: 4) {
                Text("Sin movimientos recientes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Las compras, recargas y transferencias P2P que realices con esta tarjeta aparecerán detalladas aquí.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - PREVIEW
#Preview {
    NoTransactionsPlaceholderView()
        .background(Color(.systemGroupedBackground))
}
