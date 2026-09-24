//
//  ChangePasswordView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct ChangePasswordView: View {
    @State private var viewModel = ChangePasswordViewModel()
    @Environment(AppStateManager.self) private var appStateManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            if viewModel.isLoading {
                HStack {
                    Spacer(); ProgressView("Actualizando credenciales..."); Spacer()
                }
            } else {
                Section(header: Text("Introduce tu nueva clave")) {
                    SecureField("Nueva Contraseña", text: $viewModel.newPassword)
                    SecureField("Confirmar Nueva Contraseña", text: $viewModel.confirmNewPassword)
                }
                
                // Checklist de seguridad nativo de Apple
                Section(header: Text("Requisitos de Seguridad")) {
                    let req = viewModel.passwordRequirements
                    requirementRow(text: "Mínimo 8 caracteres", isValid: req.hasMinLength)
                    requirementRow(text: "Al menos una mayúscula (A-Z)", isValid: req.hasUppercase)
                    requirementRow(text: "Al menos una minúscula (a-z)", isValid: req.hasLowercase)
                    requirementRow(text: "Al menos un número (0-9)", isValid: req.hasNumber)
                    requirementRow(text: "Al menos un carácter especial", isValid: req.hasSpecialChar)
                }
                
                Section {
                    Button {
                        if let user = appStateManager.currentUser {
                            Task { await viewModel.updatePasswordInStorage(context: modelContext, user: user) }
                        }
                    } label: {
                        Text("Actualizar Contraseña").bold().frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(viewModel.isFormValid ? Color.accentColor : Color.gray)
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .navigationTitle("Cambiar Clave")
        .disabled(viewModel.isLoading)
        .fullScreenCover(isPresented: $viewModel.isSuccessActive) {
            let successConfig = StatusFeedbackConfiguration(
                status: .success,
                title: "Contraseña Cambiada",
                subtitle: "Tu clave digital de acceso ha sido modificada correctamente. La protección de hardware ha quedado actualizada.",
                systemIcon: "key.horizontal.fill",
                buttonTitle: "Volver a Ajustes"
            )
            UniversalFeedbackView(config: successConfig) {
                viewModel.isSuccessActive = false
                dismiss() // Pop de regreso
            }
        }
    }
    
    private func requirementRow(text: String, isValid: Bool) -> some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .secondary)
            Text(text).font(.footnote).foregroundColor(isValid ? .primary : .secondary)
        }
    }
}
