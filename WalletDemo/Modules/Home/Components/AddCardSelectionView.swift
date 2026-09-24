//
//  AddCardSelectionView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct AddCardSelectionView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @Environment(HomeRouter.self) var router
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: HomeViewModel // Recibe el ViewModel del Home para inyectar los datos
    
    @State private var selectedType: CardType = .physical
    @State private var selectedBrand: CardBrand = .visa
    
    // Campos exclusivos para la tarjeta física
    @State private var inputNumber: String = ""
    @State private var inputExpiry: String = ""
    @State private var inputCVV: String = ""
    
    // Validación del formulario basada en la selección (HIG)
    var isFormInvalid: Bool {
        if selectedType == .virtual { return false } // La virtual siempre es válida porque la autogenera el sistema
        return inputNumber.count < 16 || inputExpiry.count < 5 || inputCVV.count < 3
    }
    
    var body: some View {
        Form {
            // SECCIÓN 1: TIPO DE INSTRUMENTO
            Section(header: Text("Tipo de emisión")) {
                Picker("Selecciona Tipo", selection: $selectedType) {
                    Text("Tarjeta Física 💳").tag(CardType.physical)
                    Text("Tarjeta Virtual 🌐").tag(CardType.virtual)
                }
                .pickerStyle(.segmented)
            }
            
            // SECCIÓN 2: FRANQUICIA
            Section(header: Text("Franquicia / Marca")) {
                Picker("Selecciona Marca", selection: $selectedBrand) {
                    Text("VISA").tag(CardBrand.visa)
                    Text("MasterCard").tag(CardBrand.mastercard)
                }
                .pickerStyle(.navigationLink)
            }
            
            // SECCIÓN 3: CAMPOS CONDICIONALES ANIMADOS (Solo para tarjetas físicas)
            if selectedType == .physical {
                Section(header: Text("Datos del Plástico Físico")) {
                    TextField("Número de Tarjeta (16 dígitos)", text: $inputNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: inputNumber) { _, newValue in
                            if newValue.count > 16 { inputNumber = String(newValue.prefix(16)) }
                        }
                    
                    HStack {
                        TextField("Expira (MM/AA)", text: $inputExpiry)
                            .keyboardType(.numberPad)
                            .onChange(of: inputExpiry) { _, newValue in
                                if newValue.count > 5 { inputExpiry = String(newValue.prefix(5)) }
                            }
                        
                        Divider()
                        
                        SecureField("CVV", text: $inputCVV)
                            .keyboardType(.numberPad)
                            .onChange(of: inputCVV) { _, newValue in
                                if newValue.count > 3 { inputCVV = String(newValue.prefix(3)) }
                            }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity)) // Animación elegante al desplegarse
            } else {
                // Mensaje Informativo para la Virtual conforme con HIG
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text("Las tarjetas virtuales son generadas de forma inmediata y segura por el sistema bancario central con un número único predeterminado.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // SECCIÓN 4: BOTÓN DE PROCESO ACCIÓN NATIVA
            Section {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Comunicando con el procesador...")
                            .font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    Button {
                        Task {
                            // Ejecutamos el hilo asíncrono real en SwiftData
                            await viewModel.createAndPersistCard(
                                context: modelContext,
                                fullName: "\(appStateManager.currentUser?.firstName ?? "") \(appStateManager.currentUser?.lastName ?? "")",
                                type: selectedType,
                                brand: selectedBrand,
                                customNumber: selectedType == .physical ? inputNumber : nil,
                                customExpiry: selectedType == .physical ? inputExpiry : nil
                            )
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    } label: {
                        Text(selectedType == .virtual ? "Generar Tarjeta Virtual de Inmediato" : "Vincular Tarjeta Física")
                            .bold().frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(isFormInvalid ? Color.gray : Color.accentColor)
                    .disabled(isFormInvalid)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.addedCardWithSuccess) {
            let successConfig = StatusFeedbackConfiguration(
                status: .success,
                title: "¡Tarjeta Creada con Éxito!",
                subtitle: "Su tarjeta ha sido creada con éxito. Puede acceder a ella desde la pantalla de inicio.",
                systemIcon: "creditcard.circle.fill", // Icono personalizado de perfil aprobado
                buttonTitle: "Ir a mi Billetera"
            )
            
            UniversalFeedbackView(config: successConfig) {
                viewModel.addedCardWithSuccess = false
                router.popToRoot() // 🎯 Redirección HIG al Login
            }
        }
        .navigationTitle("Nueva Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
        // Animación de redibujado del formulario al cambiar entre Física y Virtual
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedType)
    }
}
