//
//  P2PListView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct P2PListView: View {
    @State private var viewModel = P2PListViewModel()
    @State private var router = P2PRouter()
    @State private var qrViewModel = QROperationsViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    
                    if viewModel.contacts.isEmpty {
                        // PLACEHOLDER SI ESTÁ VACÍO (Conforme con HIG)
                        ContentUnavailableView(
                            "No tienes contactos",
                            systemImage: "person.crop.circle.badge.questionmark",
                            description: Text("Añade amigos para realizar transferencias P2P inmediatas de forma remota.")
                        )
                        .padding(.top, 60)
                    } else {
                        // SECCIÓN 1: FAVORITOS (Si existen)
                        let favorites = viewModel.contacts.filter { $0.isFavorite }
                        if !favorites.isEmpty {
                            Text("Favoritos ⭐")
                                .font(.footnote.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .textCase(.uppercase)
                            
                            VStack(spacing: 0) {
                                ForEach(favorites) { contact in
                                    contactRow(for: contact)
                                    if contact.id != favorites.last?.id { Divider().padding(.leading, 70) }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // SECCIÓN 2: TODOS LOS CONTACTOS
                        Text("Todos los Contactos")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .textCase(.uppercase)
                        
                        VStack(spacing: 0) {
                            ForEach(viewModel.contacts) { contact in
                                contactRow(for: contact)
                                if contact.id != viewModel.contacts.last?.id { Divider().padding(.leading, 70) }
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Enviar P2P")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.push(to: .addContactForm)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.body)
                    }
                }
            }
            // Módulos de navegación Push del Stack
            .navigationDestination(for: P2PDestination.self) { destination in
                switch destination {
                case .addContactForm:
                    AddContactFormView(viewModel: viewModel, router: router)
                }
            }
            // 🎯 REUSABILIDAD HIG: Levantamos el mismo sheet de confirmación de cobro del QR
            .sheet(isPresented: $qrViewModel.showPaymentConfirmation) {
                PaymentConfirmationSheet(viewModel: qrViewModel)
            }
            // 🎯 REUSABILIDAD HIG: Levantamos la misma pantalla universal de Éxito/Fallo adaptativa
            .fullScreenCover(isPresented: $qrViewModel.showSuccessScreen) {
                let successConfig = StatusFeedbackConfiguration(
                    status: .success,
                    title: "¡Envío Exitoso!",
                    subtitle: "Tu transferencia remota de dinero a \(qrViewModel.scannedUserName) se ha completado.",
                    voucherItems: [
                        SuccessVoucherItem(label: "Contacto", value: qrViewModel.scannedUserName),
                        SuccessVoucherItem(label: "Wallet ID", value: "@\(qrViewModel.scannedUserID)"),
                        SuccessVoucherItem(label: "Monto", value: "$\(qrViewModel.finalAmountPaid)")
                    ]
                )
                UniversalFeedbackView(config: successConfig) {
                    qrViewModel.showSuccessScreen = false
                }
            }
            .onAppear {
                viewModel.loadContacts(context: modelContext)
            }
        }
    }
}

extension P2PListView {
    // MARK: - CELDA MODULAR DE CONTACTO (Con menú contextual nativo HIG)
    @ViewBuilder
    private func contactRow(for contact: PersistentContact) -> some View {
        HStack(spacing: 16) {
            // Iniciales decorativas nativas
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(Text(String(contact.name.prefix(1))).bold().foregroundColor(.accentColor))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.body).fontWeight(.semibold)
                Text("@\(contact.walletID) • \(contact.email)")
                    .font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            // ⭐ Botón rápido de Favorito
            Button {
                viewModel.toggleFavoriteInStorage(context: modelContext, contact: contact)
            } label: {
                Image(systemName: contact.isFavorite ? "star.fill" : "star")
                    .foregroundColor(contact.isFavorite ? .yellow : .gray)
                    .font(.body)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // 💫 REUTILIZACIÓN DE ACCIÓN: Al pulsar la celda, inyectamos los datos al QRViewModel y abrimos el cobro
        .onTapGesture {
            qrViewModel.scannedUserID = contact.walletID
            qrViewModel.scannedUserName = contact.name
            qrViewModel.showPaymentConfirmation = true
        }
        // 🎛️ MECANISMO DE EDICIÓN / BORRADO CONTEXTUAL (Recomendado por HIG)
        .contextMenu {
            Button {
                viewModel.toggleFavoriteInStorage(context: modelContext, contact: contact)
            } label: {
                Label(contact.isFavorite ? "Quitar de Favoritos" : "Marcar como Favorito", systemImage: "star")
            }
            Button(role: .destructive) {
                viewModel.deleteContactFromStorage(context: modelContext, contact: contact)
            } label: {
                Label("Borrar Contacto", systemImage: "trash")
            }
        }
    }
}
