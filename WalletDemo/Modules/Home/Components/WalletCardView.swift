//
//  WalletCardView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

struct WalletCardView: View {
    // MARK: - States
    @State private var isDataVisible: Bool = true
    @State private var showDeleteConfirmation: Bool = false
    @Environment(HomeRouter.self) var router
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: HomeViewModel
    @Binding var activeCardID: UUID?
    var card: PersistentCard
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Tarjeta de Crédito/Débito
            VStack(alignment: .leading, spacing: 16) {
                // Fila Superior: Tipo de Tarjeta y Botón de Ojo
                HStack {
                    Text(card.brand.rawValue)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .italic()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack {
                        Button {
                            isDataVisible.toggle()
                        } label: {
                            Image(systemName: isDataVisible ? "eye.fill" : "eye.slash.fill")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        cardManagementMenu
                    }
                    
                }
                
                Spacer()
                
                // Fila Central: Monto Formateado
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance disponible")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(isDataVisible ? card.balance.toCurrency() : "••••••")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .animation(.snappy, value: isDataVisible)
                }
                
                Spacer()
                
                // Fila Inferior: Número de Tarjeta y Titular
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isDataVisible ? card.cardNumber : "**** **** **** ••••")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .animation(.snappy, value: isDataVisible)
                        
                        Text(card.holderName.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Chip simulado de la tarjeta
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 35, height: 25)
                }
            }
            .padding(24)
            .frame(height: 220)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: card.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 10)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .alert("¿Eliminar Tarjeta \(card.type.rawValue)?", isPresented: $showDeleteConfirmation) {
            // Botón secundario de cancelar (Rol cancel se resalta automáticamente por el sistema para protección)
            Button("Cancelar", role: .cancel) { }
            
            // Botón destructivo real que ejecuta la lógica de borrado en el ViewModel
            Button("Eliminar de mi Wallet", role: .destructive) {
                viewModel.deleteCardFromStorage(context: modelContext, card: card)
                activeCardID = viewModel.cardArray.first?.id
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } message: {
            // El texto debe ser claro, directo y advertir las consecuencias de la acción
            Text("Esta acción eliminará de forma permanente los datos de tu tarjeta \(card.brand.rawValue) de este dispositivo. No podrás realizar pagos virtuales ni transferencias asociadas a este plástico hasta que lo vuelvas a vincular.")
        }
    }
}

extension WalletCardView {
    @ViewBuilder
    private var cardManagementMenu: some View {
        Menu {
            Button {
                router.push(to: .addNewCard)
            } label: {
                Label("Añadir nueva Tarjeta", systemImage: "creditcard.fill")
            }
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Eliminar Tarjeta Actual", systemImage: "trash")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .padding(8)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}
