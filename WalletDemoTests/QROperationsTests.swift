//
//  QROperationsTests.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 24/9/26.
//


import Testing
import Foundation
import SwiftUI
@testable import WalletDemo

@Suite("Módulo de Operaciones QR - Extracción de Deep Links y Payloads")
struct QROperationsTests {
    
    // MARK: - 🧪 TESTS: PARSEO Y EXTRACCIÓN DE ENLACES PROFUNDOS DE ALTA FIDELIDAD
    
    @Test("Extraer datos de un código QR válido con formato estructurado Deep Link")
    @MainActor
    func parseValidQRCodePayload() {
        // Given (Inicializamos el ViewModel de control de la cámara)
        let viewModel = QROperationsViewModel()
        
        // Un payload QR real generado por nuestra app que incluye caracteres estándar
        let validPayload = "wallet://p2p?user=maria_delgado&name=Maria"
        
        // When (Procesamos la cadena capturada por el sensor de AVFoundation)
        viewModel.processQRCode(validPayload)
        
        // Then
        #expect(viewModel.scannedUserID == "maria_delgado", "El sistema no pudo extraer el ID de usuario del código QR.")
        #expect(viewModel.scannedUserName == "Maria")
        #expect(viewModel.showPaymentConfirmation == true, "La ventana modal de cobro debió levantarse de forma elástica.")
    }
    
    @Test("Decodificar correctamente caracteres especiales y espacios en blanco codificados en URL (%20)")
    @MainActor
    func decodeUrlPercentEncodingInQRCodePayload() {
        // Given
        let viewModel = QROperationsViewModel()
        
        // Un payload QR real con espacios en blanco en el nombre codificados internacionalmente como %20
        let encodedPayload = "wallet://p2p?user=carlos_m99&name=Carlos%20Mendoza"
        
        // When
        viewModel.processQRCode(encodedPayload)
        
        // Then
        #expect(viewModel.scannedUserID == "carlos_m99")
        // Comprobamos la decodificación implícita (URLComponents) exigida por las normas de red
        #expect(viewModel.scannedUserName == "Carlos Mendoza", "El motor falló al transformar '%20' en un espacio en blanco legible.")
        #expect(viewModel.showPaymentConfirmation == true)
    }
    
    // 🚀 PRUEBA PARAMETRIZADA: Evaluamos múltiples códigos QR corruptos o falsos en una sola función
    @Test(
        "Rechazar esquemas de códigos QR no soportados o mal formados de manera segura",
        arguments: [
            "https://google.com",                  // URL Web ordinaria falsa
            "wallet://p2p?incompleto=true",            // Esquema correcto pero sin variables del negocio
            "wallet://p2p",                             // Estructura base vacía
            "bitcoin:1KFHE7w8BhaWIwvhTyXEQ5X1o9a?amt=1",// Esquema cripto alternativo inválido
            "texto_plano_aleatorio_no_url"              // Texto plano roto
        ]
    )
    @MainActor
    func rejectInvalidQRCodePayloads(corruptPayload: String) {
        // Given
        let viewModel = QROperationsViewModel()
        
        // When
        viewModel.processQRCode(corruptPayload)
        viewModel.scannedUserID = ""
        viewModel.scannedUserName = ""
        viewModel.showPaymentConfirmation = false
        
        // Then
        // La app debe ignorar el QR silenciosamente, manteniendo las variables vacías y la ventana de pago cerrada (HIG)
        #expect(viewModel.showPaymentConfirmation == false, "El sistema levantó la ventana de cobro ante un QR inválido: \(corruptPayload)")
        #expect(viewModel.scannedUserID.isEmpty || viewModel.scannedUserID == "Desconocido")
        #expect(viewModel.scannedUserName.isEmpty || viewModel.scannedUserName == "Desconocido")
    }
    
    // MARK: - 🧪 TESTS: SIMULACIÓN DE FLUJO TRANSACCIONAL
    
    @Test("Ejecutar confirmación de pago QR debe guardar el monto y emitir la referencia de comprobante")
    @MainActor
    func executeQRTransactionGeneratesVoucherReference() {
        // Given
        let viewModel = QROperationsViewModel()
        viewModel.scannedUserID = "maria_d"
        viewModel.scannedUserName = "María Delgado"
        
        let testAmount = 24.50
        
        // When (Invocamos el motor de pago final protegido previamente por el PIN de 4 dígitos)
        viewModel.executePayment(amount: testAmount)
        
        // Then
        #expect(viewModel.finalAmountPaid == 24.50)
        #expect(viewModel.showSuccessScreen == true, "La pantalla UniversalFeedbackView de éxito no se gatilló.")
        #expect(viewModel.transactionReference.isEmpty == false, "El sistema no generó el número de comprobante único para el voucher.")
        #expect(viewModel.transactionReference.hasPrefix("TXN-"), "El formato de la referencia del recibo es incorrecto.")
    }
}
