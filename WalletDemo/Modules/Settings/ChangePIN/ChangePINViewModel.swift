//
//  ChangePINViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

// Los tres pasos sucesivos del flujo secuencial
enum PINFlowStep {
    case enterCurrent
    case enterNew
    case confirmNew
    
    var title: String {
        switch self {
        case .enterCurrent: return "PIN Actual"
        case .enterNew: return "Nuevo PIN"
        case .confirmNew: return "Confirmar PIN"
        }
    }
    
    var subtitle: String {
        switch self {
        case .enterCurrent: return "Introduce tu PIN de seguridad actual para validar tu identidad"
        case .enterNew: return "Establece tu nueva clave rápida de 4 dígitos"
        case .confirmNew: return "Vuelve a escribir el nuevo PIN para confirmar que es correcto"
        }
    }
}

@Observable
class ChangePINViewModel {
    var currentStep: PINFlowStep = .enterCurrent
    var pinCode: String = ""
    
    // Valores en memoria para comparar el proceso
    private let savedCurrentPIN: String = "1234" // PIN actual simulado de tu app
    private var temporaryNewPIN: String = ""
    
    var attemptsOffset: CGFloat = 0 // Animación de sacudida si falla
    let maxDigits: Int = 4
    
    // Almacena el resultado del éxito para avisarle a la vista
    var isPINChangeSuccessful: Bool = false
    
    func processDigit(_ digit: String, onSuccessStep: () -> Void) {
        guard pinCode.count < maxDigits else { return }
        
        // Respuesta háptica leve por toque (HIG)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        pinCode.append(digit)
        
        // Al completar los 4 dígitos del paso activo
        if pinCode.count == maxDigits {
            // Retraso de un tercio de segundo para que el usuario vea el último círculo llenarse
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.evaluateStep(onSuccessStep: onSuccessStep)
            //}
        }
    }
    
    func deleteLastDigit() {
        if !pinCode.isEmpty { pinCode.removeLast() }
    }
    
    private func evaluateStep(onSuccessStep: () -> Void) {
        switch currentStep {
        case .enterCurrent:
            if pinCode == savedCurrentPIN {
                advanceStep(to: .enterNew)
            } else {
                triggerErrorAnimation()
            }
            
        case .enterNew:
            temporaryNewPIN = pinCode
            pinCode = "" // Limpiamos para el siguiente paso
            advanceStep(to: .confirmNew)
            
        case .confirmNew:
            if pinCode == temporaryNewPIN {
                // Éxito Definitivo: Notificación física fuerte de logro
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isPINChangeSuccessful = true
                onSuccessStep()
            } else {
                // Error: No coincidió el nuevo PIN en la confirmación
                triggerErrorAnimation()
                // Devolvemos el flujo al paso de creación para que lo intente de nuevo
                currentStep = .enterNew
            }
        }
    }
    
    private func advanceStep(to nextStep: PINFlowStep) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = nextStep
            pinCode = "" // Reseteo de casillas para el nuevo contexto
        }
    }
    
    private func triggerErrorAnimation() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation(.default) { attemptsOffset = 15 }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) { attemptsOffset = 0 }
        pinCode = ""
    }
}
