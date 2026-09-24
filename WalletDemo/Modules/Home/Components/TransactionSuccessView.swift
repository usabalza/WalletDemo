//
//  TransactionSuccessView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct TransactionSuccessView: View {
    var viewModel: QROperationsViewModel
    
    // Estados para controlar el retraso de las micro-animaciones al entrar
    @State private var animateCheckmark = false
    @State private var animateVoucher = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 1. ICONO ANIMADO DE ÉXITO (HIG standard)
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.4)
                    .opacity(animateCheckmark ? 1.0 : 0.0)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.2)
                    .rotationEffect(.degrees(animateCheckmark ? 0 : -45))
            }
            
            // Textos de Éxito
            VStack(spacing: 8) {
                Text("¡Transferencia Exitosa!")
                    .font(.title2.bold())
                Text("El dinero ha sido enviado correctamente.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // 2. COMPROBANTE / VOUCHER DIGITAL
            VStack(spacing: 20) {
                // Cabecera del Recibo
                VStack(spacing: 4) {
                    Text("Monto Transferido")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("$\(viewModel.finalAmountPaid, specifier: "%.2f")")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.top, 10)
                
                Divider()
                    .overlay(Color(.systemGray4))
                
                // Detalles de la transacción
                VStack(spacing: 14) {
                    VoucherRow(label: "Destinatario", value: viewModel.scannedUserName)
                    VoucherRow(label: "Wallet ID", value: "@\(viewModel.scannedUserID)")
                    VoucherRow(label: "Fecha", value: Date().formatted(.dateTime.day().month(.wide).year().hour().minute()))
                    VoucherRow(label: "Referencia", value: viewModel.transactionReference)
                    
                    VoucherRow(label: "Estado", value: "Aprobado  ✓", color: .green)
                }
                .padding(.bottom, 10)
            }
            .padding(24)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.03), radius: 15, x: 0, y: 8)
            .padding(.horizontal, 24)
            // Animación de entrada con desfase para el voucher
            .offset(y: animateVoucher ? 0 : 30)
            .opacity(animateVoucher ? 1.0 : 0.0)
            
            Spacer()
            
            // 3. BOTÓN IMPERATIVO DE CIERRE
            Button {
                // Cerramos la pantalla completa regresando al estado inicial
                viewModel.showSuccessScreen = false
            } label: {
                Text("Volver al Inicio")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Orquestación secuencial de micro-animaciones de entrada
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                animateCheckmark = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25)) {
                animateVoucher = true
            }
        }
    }
}

// Componente modular para las filas internas del voucher
struct VoucherRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .lineLimit(1)
        }
    }
}
