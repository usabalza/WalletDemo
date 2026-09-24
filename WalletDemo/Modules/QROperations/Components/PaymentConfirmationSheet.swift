//
//  PaymentConfirmationSheet.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct PaymentConfirmationSheet: View {
    var viewModel: QROperationsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amountToPay: String = ""
    @State private var isPresentingPINVerification: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {

            Spacer()
            
            Text("Enviar Pago por QR")
                .font(.headline)
            
            // Tarjeta del Destinatario
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(Text(String(viewModel.scannedUserName.prefix(1))).bold().foregroundColor(.accentColor))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.scannedUserName)
                        .font(.body).fontWeight(.semibold)
                    Text("@\(viewModel.scannedUserID)")
                        .font(.footnote).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            // Entrada de Monto
            VStack(spacing: 8) {
                Text("Monto a Transferir")
                    .font(.caption).foregroundColor(.secondary)
                TextField("$0.00", text: $amountToPay)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            // Botón Prominente de Envío
            Button {
                // En lugar de procesar directo, abrimos el validador del PIN
                isPresentingPINVerification = true
            } label: {
                Text("Confirmar y Enviar Dinero")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(amountToPay.isEmpty ? Color.gray : Color.accentColor)
                    .cornerRadius(12)
            }
            .disabled(amountToPay.isEmpty)
            // 🎯 CONTROL DE SEGURIDAD SECUENCIAL (Full Screen Cover para máxima concentración)
            .fullScreenCover(isPresented: $isPresentingPINVerification) {
                PINVerificationView(isPresented: $isPresentingPINVerification) {
                    if let amount = Double(amountToPay) {
                        // 1. Ejecutamos el pago pasándole el monto real
                        viewModel.executePayment(amount: amount)
                        // 2. Cerramos el sheet de confirmación base
                        viewModel.showPaymentConfirmation = false
                    }
                }
            }

        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
    }
}
