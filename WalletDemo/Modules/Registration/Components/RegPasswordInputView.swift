//
//  RegPasswordInputView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct RegPasswordInputView: View {
    @Environment(RegistrationViewModel.self) var viewModel
    @Environment(RegistrationRouter.self) var router
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        Form {
            Section(header: Text("Crea tu clave segura")) {
                SecureField("Contraseña", text: $viewModelBindable.password)
                SecureField("Confirmar Contraseña", text: $viewModelBindable.confirmPassword)
            }
            
            // 📋 CHECKLIST VISUAL DE SEGURIDAD (HIG)
            Section(header: Text("Requisitos de Seguridad")) {
                let req = viewModel.passwordRequirements
                requirementRow(text: "Mínimo 8 caracteres", isValid: req.hasMinLength)
                requirementRow(text: "Al menos una mayúscula (A-Z)", isValid: req.hasUppercase)
                requirementRow(text: "Al menos una minúscula (a-z)", isValid: req.hasLowercase)
                requirementRow(text: "Al menos un número (0-9)", isValid: req.hasNumber)
                requirementRow(text: "Al menos un carácter especial (ej: @, #, $)", isValid: req.hasSpecialChar)
            }
            
            Section {
                Button("Continuar") {
                    router.push(to: .userData)
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.passwordRequirements.isValid || viewModel.password != viewModel.confirmPassword)
            }
        }
        .navigationTitle("Contraseña")
    }
    
    private func requirementRow(text: String, isValid: Bool) -> some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .secondary)
            Text(text)
                .font(.footnote)
                .foregroundColor(isValid ? .primary : .secondary)
        }
    }
}
