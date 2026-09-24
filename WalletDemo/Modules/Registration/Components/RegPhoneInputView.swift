//
//  RegPhoneInputView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct RegPhoneInputView: View {
    @Environment(RegistrationViewModel.self) var viewModel
    @Environment(RegistrationRouter.self) var router
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        Form {
            Section(header: Text("Número celular")) {
                HStack {
                    // Menú desplegable para los prefijos de bandera (HIG Perfect)
                    Menu {
                        ForEach(viewModel.countryCodes, id: \.code) { item in
                            Button("\(item.flag) \(item.code) - \(item.name)") {
                                viewModel.selectedCountryCode = item.code
                                viewModel.selectedCountryFlag = item.flag
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(viewModel.selectedCountryFlag) \(viewModel.selectedCountryCode)")
                            Image(systemName: "chevron.down").font(.caption2)
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                    
                    TextField("000 000 0000", text: $viewModelBindable.phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            
            Section {
                Button("Enviar Código de Validación") {
                    self.viewModel.isOTPReady = false
                    router.push(to: .otpPhone)
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isPhoneStepValid)
            }
        }
        .navigationTitle("Paso 2: Teléfono")
    }
}
