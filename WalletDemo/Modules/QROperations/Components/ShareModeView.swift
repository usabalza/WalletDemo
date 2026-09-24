//
//  ShareModeView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct ShareModeView: View {
    @Environment(AppStateManager.self) private var appStateManager
    var viewModel: QROperationsViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // TARJETA DE RECAUDACIÓN (CONTENEDOR DEL QR)
            VStack(spacing: 20) {
                // Info del perfil del Usuario
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(appStateManager.currentUser?.firstName ?? "") \(appStateManager.currentUser?.lastName ?? "")")
                            .font(.headline)
                        Text("@juan_perez • Wallet ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Divider()
                
                // CÓDIGO QR GENERADO (Placeholder visual de alta fidelidad)
                ZStack {
                    if let qrImage = QRCodeGenerator.generate(from: viewModel.qrPayload) {
                        qrImage
                            .resizable()
                        // ✨ REGLA HIG CRÍTICA: Desactiva el suavizado para que el QR sea nítido y escaneable
                            .interpolation(.none)
                            .frame(width: 200, height: 200)
                            .padding(16)
                            .background(Color.white) // Fondo blanco obligatorio para contraste de lectura
                            .cornerRadius(12)
                    } else {
                        // Respaldo en caso de error de generación
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Error al generar el código")
                                .font(.caption)
                        }
                        .frame(width: 200, height: 200)
                    }
                }
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                
                Text("Muestra este código para recibir una transferencia P2P instantánea")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .padding(.horizontal, 30)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            
            // 🚀 SHARE LINK NATIVO DE iOS 16+ (HIG Perfect para exportar)
            ShareLink(item: viewModel.qrPayload) {
                Label("Compartir enlace de cobro", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}
