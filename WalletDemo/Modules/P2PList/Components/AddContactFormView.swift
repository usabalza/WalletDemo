//
//  AddContactFormView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct AddContactFormView: View {
    var viewModel: P2PListViewModel
    var router: P2PRouter
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var walletID: String = ""
    @State private var email: String = ""
    
    var isFormInvalid: Bool {
        name.isEmpty || walletID.isEmpty || email.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Información Personal")) {
                TextField("Nombre Completo", text: $name)
                    .textContentType(.name)
                TextField("Correo Electrónico", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section(header: Text("Credenciales de Billetera")) {
                HStack {
                    Text("@")
                        .foregroundColor(.secondary)
                    TextField("WalletIDÚnico", text: $walletID)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section {
                Button {
                    Task {
                        await viewModel.createAndPersistContact(
                            context: modelContext,
                            name: name,
                            walletID: walletID,
                            email: email
                        )
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        router.popToRoot()
                    }
                } label: {
                    Text("Guardar Contacto")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.white)
                .listRowBackground(isFormInvalid ? Color.gray : Color.accentColor)
                .disabled(isFormInvalid)
            }
        }
        .navigationTitle("Nuevo Contacto")
        .navigationBarTitleDisplayMode(.inline)
    }
}
