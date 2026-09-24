//
//  ChangeProfileView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct ChangeProfileView: View {
    @State private var viewModel = ChangeProfileViewModel()
    @Environment(AppStateManager.self) private var appStateManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Sincronizando con el servidor...")
                    Spacer()
                }
            } else {
                Section(header: Text("Información Personal")) {
                    TextField("Nombres", text: $viewModel.firstName)
                    TextField("Apellidos", text: $viewModel.lastName)
                    TextField("Correo Electrónico", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Text("Fecha de Nacimiento: \(viewModel.birthDate.toDateFromISO8601()?.toShortString() ?? "")")
                }
                
                Section(header: Text("Identificación Oficial")) {
                    Picker("Documento", selection: $viewModel.documentType) {
                        Text("DNI").tag("DNI")
                        Text("Pasaporte").tag("Pasaporte")
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Número de Documento", text: $viewModel.documentNumber)
                }
                
                Section {
                    Button {
                        if let user = appStateManager.currentUser {
                            Task { await viewModel.updateProfileInStorage(context: modelContext, user: user) }
                        }
                    } label: {
                        Text("Guardar Cambios").bold().frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }
        }
        .navigationTitle("Modificar Datos")
        .disabled(viewModel.isLoading)
        .onAppear {
            // 🎯 PRECARGA HIG: Al aparecer la pantalla, inyectamos los textos actuales guardados
            if let user = appStateManager.currentUser {
                viewModel.loadCurrentUserData(user: user)
            }
        }
        // 🔮 PANTALLA UNIVERSAL ADAPTATIVA: Muestra el recibo de éxito antes de hacer el pop
        .fullScreenCover(isPresented: $viewModel.isSuccessActive) {
            let successConfig = StatusFeedbackConfiguration(
                status: .success,
                title: "Perfil Actualizado",
                subtitle: "Tus datos personales han sido modificados de forma exitosa en el servidor encriptado.",
                systemIcon: "person.crop.circle.badge.checkmark",
                buttonTitle: "Volver a Ajustes"
            )
            UniversalFeedbackView(config: successConfig) {
                viewModel.isSuccessActive = false
                dismiss() // Pop automático
            }
        }
    }
}
