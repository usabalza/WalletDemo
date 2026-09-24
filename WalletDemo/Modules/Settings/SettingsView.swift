//
//  SettingsView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var router = SettingsRouter()
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        NavigationStack(path: $router.path) {
            List {
                ForEach(SettingsSection.allCases) { section in
                    Section(header: Text(section.rawValue)) {
                        
                        // Modificamos el ciclo para interceptar la acción de contraseña de forma especial
                        if section == .security {
                            // Opción A: Modificar PIN (Sigue siendo Push directo)
                            NavigationLink(value: SettingsDestination.changePIN) {
                                HStack(spacing: 12) {
                                    settingsIcon(name: "lock.fill", color: .green)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Modificar PIN").font(.body).fontWeight(.medium)
                                        Text("Clave de acceso rápida de 4 dígitos").font(.caption).foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            // 🚀 Opción B: Modificar Contraseña (HIG: Cambiado a Botón para disparar el Cover de Seguridad)
                            passwordButton
                            
                            // Interruptor de Biometría
                            HStack(spacing: 12) {
                                settingsIcon(name: "faceid", color: .purple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Biometría").font(.body).fontWeight(.medium)
                                    Text("Acceso rápido con FaceID / TouchID").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $viewModel.isBiometricsEnabled).labelsHidden()
                            }
                            .padding(.vertical, 4)
                            
                        } else {
                            // Render estándar para el resto de las secciones (Datos de usuario y Legal)
                            ForEach(viewModel.items(for: section)) { item in
                                NavigationLink(value: item.destination) {
                                    HStack(spacing: 12) {
                                        settingsIcon(name: item.iconName, color: item.iconColor)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title).font(.body).fontWeight(.medium)
                                            Text(item.subtitle).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                
                // Sección de Cerrar Sesión
                Section {
                    Button(role: .destructive, action: { appStateManager.logout() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward").font(.body).bold()
                            Text("Cerrar Sesión").font(.body).fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ajustes")
            // Destinos de navegación Push limpios y directos
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .editProfile:
                    ChangeProfileView()
                case .changePIN:
                    ChangePINView()
                case .changePassword:
                    ChangePasswordView()
                case .termsAndConditions:
                    TermsAndConditionsSheet()
                case .aboutMe:
                    AboutMeView()
                }
            }
            // 🎯 CAPA DE SEGURIDAD MÁXIMA: FullScreenCover acoplado a la validación intermedia del PIN
            .fullScreenCover(isPresented: $viewModel.isVerifyingPINForPassword) {
                PINVerificationView(isPresented: $viewModel.isVerifyingPINForPassword) {
                    // 🚀 CALLBACK DE ÉXITO: Despachamos de forma asíncrona hacia el Push del Stack
                    DispatchQueue.main.async {
                        router.push(to: .changePassword)
                    }
                }
            }
        }
    }
    
    
}

extension SettingsView {
    @ViewBuilder
    private func settingsIcon(name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.footnote).bold()
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(color)
            .cornerRadius(8)
    }
    
    @ViewBuilder
    private var passwordButton: some View {
        Button {
            viewModel.isVerifyingPINForPassword = true
        } label: {
            HStack(spacing: 12) {
                settingsIcon(name: "key.fill", color: .yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modificar Contraseña")
                        .font(.body).fontWeight(.medium)
                        .foregroundColor(.primary) // Mantiene la estética de la fila
                    Text("Requiere validación de PIN previa")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                // Añadimos manualmente el Chevron decorativo que se pierde al pasar de NavigationLink a Button
                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
