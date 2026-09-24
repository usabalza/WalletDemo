//
//  LoginTraditionalView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct LoginTraditionalView: View {
    @Bindable var viewModel: LoginViewModel
    @Environment(AppStateManager.self) private var appStateManager
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Form {
            Section(header: Text("Ingresa tus credenciales")) {
                TextField("Correo Electrónico", text: $viewModel.loginEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Contraseña", text: $viewModel.loginPassword)
            }
            
            // ⚠️ MENSAJE DE ADVERTENCIA INLINE (Conforme con HIG)
            if let error = viewModel.inlineErrorMessage {
                Section {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .listRowBackground(Color.clear)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section {
                if viewModel.isLoading {
                    // Spinner elegante de carga que simula la respuesta de los servidores
                    HStack {
                        Spacer()
                        ProgressView("Verificando tu identidad...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } else {
                    Button {
                        // Disparamos el hilo asíncrono de autenticación contra el disco
                        Task {
                            await viewModel.authenticateUserWithAPI(context: modelContext)
                        }
                    } label: {
                        Text("Iniciar Sesión")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(viewModel.isTraditionalFormValid ? Color.accentColor : Color(.systemGray4))
                    .disabled(!viewModel.isTraditionalFormValid)
                }
            }
            
            Section {
                Button("¿No tienes cuenta? Regístrate aquí") {
                    appStateManager.logout() // Te regresa de forma limpia al flujo del Onboarding
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.footnote)
            }
        }
        .navigationTitle("Iniciar Sesión")
    }
}
