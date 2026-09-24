//
//  RegEmailInputView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct RegEmailInputView: View {
    @Environment(RegistrationViewModel.self) var viewModel
    @Environment(RegistrationRouter.self) var router
    @State private var showTermsSheet = false
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        Form {
            Section(header: Text("Correo de acceso")) {
                TextField("Correo Electrónico", text: $viewModelBindable.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                TextField("Confirmar Correo", text: $viewModelBindable.confirmEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section {
                Toggle(isOn: $viewModelBindable.acceptedTerms) {
                    HStack(spacing: 4) {
                        Text("He leído los")
                        Button("Términos y Condiciones") {
                            showTermsSheet = true
                        }
                        .font(.body.bold())
                        .foregroundColor(.accentColor)
                    }
                }
            }
            
            Section {
                Button("Continuar") {
                    router.push(to: .otpEmail)
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isEmailStepValid)
            }
        }
        .navigationTitle("Registro")
        .sheet(isPresented: $showTermsSheet) {
            TermsAndConditionsSheet()
        }
    }
}

struct TermsAndConditionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        //NavigationStack {
            ScrollView {
                Text("Términos Legales de la Wallet...\n\nAquí se despliega el texto legal conforme a las HIG de Apple. El usuario lee los parámetros antes de continuar con la creación de su cuenta bancaria simulada.")
                    .padding()
            }
            .navigationTitle("Términos y Condiciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Cerrar") { dismiss() } }
            }
            .presentationDragIndicator(.visible)
        //}
    }
}
