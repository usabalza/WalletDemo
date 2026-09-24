//
//  RegOTPValidationView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

public enum OTPType {
    case email
    case phone
}

struct RegOTPValidationView: View {
    @Environment(RegistrationRouter.self) var router
    @Environment(RegistrationViewModel.self) var viewModel
    var otpType: OTPType
    //@Binding var otpValue: String
    var numberOfDigits: Int = 6 // Totalmente configurable
    
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text(otpType == .email ? "Verifica tu email" : "Verifica tu número de teléfono")
                    .font(.title2.bold())
                Text(otpType == .email ? "Te hemos enviado el código al correo electrónico \(viewModel.email)" : "Te hemos enviado el código al número de teléfono \(viewModel.phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            // 🔲 CASILLAS SEGMENTADAS SIMULADAS
            
            OTPSegmentedInput(codeLength: numberOfDigits, otpCode: $viewModelBindable.otpCode)
                .padding(.vertical, 20)
            
            VStack(alignment: .center) {
                
                if viewModel.countdownTimer.isRunning {
                    Text("Tiempo restante: \(viewModel.countdownTimer.timeFormatted) seg.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Button {
                        viewModel.resendCode()
                    } label: {
                        Text("Volver a enviar el código")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            
            Text("Tip: El OTP para este portafolio es 111111")
                .font(.caption2).foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.top, 40)
        .background(Color(.systemGroupedBackground))
        .onChange(of: viewModel.otpCode) { _, newValue in
            viewModel.handleCodeChange(to: newValue)
        }
        .onChange(of: viewModel.isOTPReady) {
            if otpType == .email {
                self.router.push(to: .phone)
            } else {
                self.router.push(to: .password)
            }
        }
        .onAppear {
            viewModel.countdownTimer.start()
            isKeyboardFocused = true
        }
        
    }
}
