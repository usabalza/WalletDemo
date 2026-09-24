//
//  HomeView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStateManager.self) private var appStateManager
    @State private var viewModel = HomeViewModel()
    @State private var router = HomeRouter()
    
    // 🔑 CLAVE: Rastraea el ID de la tarjeta que el usuario está viendo actualmente
    @State private var activeCardID: UUID?
    
    // Propiedad calculada para obtener los datos de la tarjeta visible en pantalla
    private var activeCard: PersistentCard? {
        viewModel.cardArray.first(where: { $0.id == activeCardID }) ?? viewModel.cardArray.first
    }
    
    private let initialPlaceholders = (0..<6).map { _ in UUID() }
    private let paginationPlaceholders = (0..<2).map { _ in UUID() }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    welcomeGreeting
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            if viewModel.cardArray.isEmpty {
                                NoCardsPlaceholderView {
                                    router.push(to: .addNewCard)
                                }
                            }
                            else {
                                cardListContent
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    // 🎯 Sincroniza la posición del scroll con nuestra variable de estado
                    .scrollPosition(id: $activeCardID)
                    
                    Divider()
                    
                    if let card = activeCard {
                        if card.transactions.isEmpty {
                            // 🎯 Cambio: Inyectamos el nuevo placeholder sutil si la tarjeta no registra transacciones
                            NoTransactionsPlaceholderView()
                        }
                        else {
                            transactionFullComponent
                        }
                    }
                }
                
            }
            .padding()
            
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .allTransactions: TransactionsView(transactions: activeCard?.transactions ?? [])
                case .addNewCard: AddCardSelectionView(viewModel: viewModel)
                }
            }
            .sheet(item: $router.activeSheet) { sheet in
                switch sheet {
                case .transactionDetails(let transaction):
                    TransactionSheetView(transaction: transaction)
                }
            }
            .task {
                // Leemos las tarjetas reales persistidas del disco SQLite al renderizar
                await viewModel.loadWalletData(context: modelContext)
                
                if let firstCard = viewModel.cardArray.first {
                    activeCardID = firstCard.id
                }
            }
        }
        .environment(router)
    }
}

extension HomeView {
    @ViewBuilder
    private var welcomeGreeting: some View {
        // 🌟 NUEVA CABECERA HIG DE BIENVENIDA DINÁMICA
        HStack(spacing: 12) {
            // Círculo decorativo con la inicial del usuario real en el disco
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(appStateManager.currentUser?.firstName.prefix(1) ?? "U"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                // Si SwiftData no encuentra al usuario por algún motivo, usa "Invitado" como respaldo seguro (HIG)
                Text("Hola, \(appStateManager.currentUser?.firstName ?? "Invitado") 👋")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("¿Qué deseas hacer hoy?")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    @ViewBuilder
    private var loadCardPlaceholder: some View {
        CardPlaceholder()
    }
    
    @ViewBuilder
    private var loadRowPlaceholders: some View {
        ForEach(initialPlaceholders, id: \.self) { _ in
            RowPlaceholder()
        }
    }
    
    @ViewBuilder
    private var cardSlider: some View {
        ForEach(viewModel.cardArray) { card in
            WalletCardView(viewModel: viewModel, activeCardID: $activeCardID, card: card)
        }
    }
    
    @ViewBuilder
    private var transactionFullComponent: some View {
        HStack {
            Text("Mis movimientos")
                .fontWeight(.bold)
            Spacer()
            Button {
                router.push(to: .allTransactions)
            } label: {
                Text("Ver más")
            }
        }
        .padding()
        
        if !viewModel.cardArray.isEmpty {
            WalletAnalyticsCard(dataset: viewModel.weeklyExpenses)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        
        LazyVStack(spacing: 12) {
            transactionListContent
        }
    }
    
    @ViewBuilder
    private var transactionListContent: some View {
        if viewModel.cardArray.isEmpty && viewModel.isLoading  {
            loadRowPlaceholders
        } else {
            mainListView(transactions: activeCard?.transactions ?? [])
        }
        
    }
    
    @ViewBuilder
    private var cardListContent: some View {
        if viewModel.cardArray.isEmpty && viewModel.isLoading  {
            loadCardPlaceholder
                .padding(.horizontal, 10)
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
        } else {
            cardSlider
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
        }
        
    }
    
    @ViewBuilder
    private func mainListView(transactions: [PersistentTransaction]) -> some View {
        ForEach(transactions) { item in
            Button {
                router.presentSheet(.transactionDetails(item))
            } label: {
                TransactionCell(transaction: item)
            }
            .contentShape(Rectangle())
            .tint(.black)
        }
    }
}
