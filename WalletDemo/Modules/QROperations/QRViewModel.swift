//
//  QRViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import AVFoundation

// Representa los dos modos del módulo QR
enum QRMode: Int, CaseIterable, Identifiable {
    case scan = 0
    case share = 1
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .scan: return "Escanear QR"
        case .share: return "Mi Código"
        }
    }
}

@Observable
class QROperationsViewModel {
    var selectedMode: QRMode = .scan
    var isCameraAuthorized: Bool = true
    var alertMessage: String?
    var showPaymentConfirmation: Bool = false
    
    var showSuccessScreen: Bool = false
    var finalAmountPaid: Double = 0.0
    var transactionReference: String = ""
    
    let walletUserID: String = "juan_perez_99"
    let walletFullName: String = "Juan Pérez"
    
    // Datos del usuario escaneado que se extraerán del código QR
    var scannedUserID: String = ""
    var scannedUserName: String = ""
    
    // 🔗 El Payload que viajará encriptado/estructurado dentro del código QR
    var qrPayload: String {
        return "wallet://p2p?user=\(walletUserID)&name=\(walletFullName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    }
    
    // 📷 Solicitar permisos de cámara en dispositivo físico
    func requestCameraPermission() {
    #if targetEnvironment(simulator)
        // En el simulador saltamos la validación de hardware
        self.isCameraAuthorized = true
    #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = authorized
                }
            }
        case .authorized:
            self.isCameraAuthorized = true
        default:
            self.isCameraAuthorized = false
        }
    #endif
    }
    
    // 🔍 Procesar el string detectado por la cámara o el simulador
    func processQRCode(_ code: String) {
        guard let url = URL(string: code), url.scheme == "wallet", url.host == "p2p" else {
            return // Código QR no soportado o inválido
        }
        
        // Extraer parámetros del Deep Link (user y name)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        self.scannedUserID = components?.queryItems?.first(where: { $0.name == "user" })?.value ?? "Desconocido"
        self.scannedUserName = components?.queryItems?.first(where: { $0.name == "name" })?.value ?? "Desconocido"
        
        // Abrir la confirmación de pago con una animación sutil
        withAnimation(.spring()) {
            self.showPaymentConfirmation = true
        }
    }
    
    // Ejecutada cuando el PIN de 4 dígitos es correcto
    func executePayment(amount: Double) {
        self.finalAmountPaid = amount
        // Generamos un número de comprobante único simulado
        self.transactionReference = "TXN-\(Int.random(in: 100000...999999))"
        
        // Disparamos la pantalla de éxito animada
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            self.showSuccessScreen = true
        }
    }
}
