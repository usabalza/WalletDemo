//
//  TransactionSheetView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

struct TransactionSheetView: View {
    let transaction: PersistentTransaction
    @Environment(HomeRouter.self) var router// Recibe el router para poder cerrarse programáticamente
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            // Icono Dinámico Grande
            switch transaction.tag {
            case .qrPayment, .p2pSent:
                Image(systemName: "arrow.down.left.circle")
                    .foregroundStyle(Color.red)
                    .font(.system(size: 64))
                    .padding(.top, 10)
            case .qrRecharge, .p2pReceived:
                Image(systemName: "arrow.up.right.circle")
                    .foregroundStyle(Color.green)
                    .font(.system(size: 64))
                    .padding(.top, 10)
                
            case .all:
                EmptyView()
            }
            
            // Textos Principales
            VStack(spacing: 8) {
                Text(transaction.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text(transaction.tagRaw)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Monto Héroe
            Text("\(transaction.tag == .qrRecharge || transaction.tag == .p2pReceived ? "+" : "-") \(transaction.amount.toCurrency())")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(transaction.tag == .qrRecharge || transaction.tag == .p2pReceived ? .green : .red)
            
            // Lista Informativa Estilo Recibo
            VStack(spacing: 14) {
                DetailRow(label: "Fecha y Hora", value: transaction.date.toShortString())
                Divider()
                DetailRow(label: "ID de Transacción", value: transaction.id.uuidString.prefix(14) + "...")
                Divider()
                DetailRow(label: "Estado", value: "Autorizado ✅", color: .green)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
        .background(Color(.systemGroupedBackground))
        // 🔮 CONTROL DE TAMAÑO HIG: El sheet solo se abre hasta la mitad de la pantalla de forma nativa
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// Componente helper para filas de detalle plano
struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
}
