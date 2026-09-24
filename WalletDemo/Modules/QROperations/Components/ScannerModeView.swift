//
//  ScannerModeView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct ScannerModeView: View {
    @Bindable var viewModel: QROperationsViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                
                // ⚙️ COMPILACIÓN CONDICIONAL INTELIGENTE
#if targetEnvironment(simulator)
                // Vista del Simulador: Caja negra interactiva con botón de inyección
                VStack(spacing: 16) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Cámara no disponible en el Simulador")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Button {
                        // Simulamos que escaneamos el QR de un tercero (ej: María Delgado)
                        viewModel.processQRCode("wallet://p2p?user=maria_d&name=Maria%20Delgado")
                    } label: {
                        Text("Simular Lectura de QR Exitosa")
                            .font(.caption.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(24)
#else
                // Vista de Dispositivo Físico: Feed de video real de la cámara
                if viewModel.isCameraAuthorized {
                    CameraPreviewView { scannedCode in
                        viewModel.processQRCode(scannedCode)
                    }
                    .cornerRadius(24)
                } else {
                    ContentUnavailableView("Sin acceso a la cámara",
                                           systemImage: "camera.metering.unknown",
                                           description: Text("Por favor otorga permisos en los Ajustes del sistema."))
                }
#endif
                
                // Retícula guía de enfoque superpuesta (Válida para ambos entornos)
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: []))
                    .frame(width: 240, height: 240)
                    /*.phaseAnimator([false, true]) { content, phase in
                        content.opacity(phase ? 0.6 : 1.0)
                    } animation: { _ in
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                    }*/
            }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.horizontal, 30)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            
            Spacer()
        }
        // 🎯 DISPARADOR DEL SHEET: Se abre el Recibo de transferencia al escanear
        .sheet(isPresented: $viewModel.showPaymentConfirmation) {
            PaymentConfirmationSheet(viewModel: viewModel)
        }
    }
}

