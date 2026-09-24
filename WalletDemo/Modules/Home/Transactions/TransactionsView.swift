//
//  TransactionsView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct TransactionsView: View {
    @State private var viewModel: TransactionsViewModel
    @Environment(HomeRouter.self) var router
    
    // Inicializador que inyecta las transacciones de la tarjeta seleccionada
    init(transactions: [PersistentTransaction]) {
        self._viewModel = State(initialValue: TransactionsViewModel(transactions: transactions))
        //self.router = router
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. BARRA HORIZONTAL DE FILTRADO POR TAGS
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    tagSelector
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            
            // 2. LISTADO MODULAR CON SCROLLVIEW + LAZYVSTACK
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                    if viewModel.groupedTransactions.isEmpty {
                        VStack(spacing: 12) {
                            Spacer(minLength: 100)
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No hay movimientos en esta categoría")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Iteramos sobre los grupos ordenados por fecha
                        transactionSection
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 🎨 FORMATO DE FECHA HIG: Crea el Header flotante de cada sección
    private func sectionHeaderView(for date: Date) -> some View {
        Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGroupedBackground).opacity(0.95)) // Sutil efecto translúcido al flotar
    }
}

extension TransactionsView {
    
    @ViewBuilder
    private var transactionSection: some View {
        ForEach(viewModel.groupedTransactions, id: \.key) { date, transactions in
            Section(header: sectionHeaderView(for: date)) {
                VStack(spacing: 0) {
                    ForEach(transactions) { transaction in
                        Button {
                            router.presentSheet(.transactionDetails(transaction))
                        } label: {
                            TransactionCell(transaction: transaction)
                        }
                        .contentShape(Rectangle())
                        .tint(.black)
                        
                        if transaction.id != transactions.last?.id {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var tagSelector: some View {
        ForEach(TransactionTag.allCases) { tag in
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.selectedTag = tag
                }
            } label: {
                HStack(spacing: 6) {
                    //Image(systemName: tag.iconName)
                    Text(tag.rawValue)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(viewModel.selectedTag == tag ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(viewModel.selectedTag == tag ? .white : .primary)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

