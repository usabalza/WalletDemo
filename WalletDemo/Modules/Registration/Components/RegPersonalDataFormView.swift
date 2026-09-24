//
//  RegPersonalDataFormView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct RegPersonalDataFormView: View {
    @Environment(RegistrationViewModel.self) var viewModel
    @Environment(RegistrationRouter.self) var router
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        Form {
            Section(header: Text("Datos Personales")) {
                
                TextField("Nombres", text: $viewModelBindable.firstName)
                TextField("Apellidos", text: $viewModelBindable.lastName)
                
                DatePicker("Fecha de Nacimiento", selection: $viewModelBindable.birthDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Género", selection: $viewModelBindable.gender) {
                    Text("Masculino").tag("Masculino")
                    Text("Femenino").tag("Femenino")
                    Text("Otro").tag("Otro")
                }
            }
            
            Section(header: Text("Identificación Oficial")) {
                Picker("Documento", selection: $viewModelBindable.documentType) {
                    Text("DNI / Cédula").tag("DNI")
                    Text("Pasaporte").tag("Pasaporte")
                }
                .pickerStyle(.segmented)
                
                TextField("Número de Documento", text: $viewModelBindable.documentNumber)
                    .keyboardType(.numberPad)
            }
            
            Section {
                if viewModel.isLoading {
                    // Muestra un indicador de carga para respetar los tiempos simulados de la API
                    HStack {
                        Spacer()
                        ProgressView("Procesando tu alta bancaria...")
                        Spacer()
                    }
                } else {
                    Button {
                        // Disparamos una tarea asíncrona en el hilo principal
                        Task {
                            await viewModel.finalizeRegistration(context: modelContext)
                        }
                    } label: {
                        Text("Finalizar Registro")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(viewModel.documentNumber.isEmpty || viewModel.firstName.isEmpty ? Color.gray : Color.accentColor)
                    .disabled(viewModel.documentNumber.isEmpty || viewModel.firstName.isEmpty)
                }
            }
        }
        .navigationTitle("Tu Perfil")
    }
}
