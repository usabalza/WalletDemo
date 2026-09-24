//
//  QROperationsView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct QROperationsView: View {
    @State private var viewModel = QROperationsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 🎛️ CONTROL DE SEGMENTOS NATIVO (Recomendado por HIG)
                Picker("Modo QR", selection: $viewModel.selectedMode) {
                    ForEach(QRMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // CONTENIDO DINÁMICO CON ANIMACIÓN
                ZStack {
                    switch viewModel.selectedMode {
                    case .scan:
                        ScannerModeView(viewModel: viewModel)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    case .share:
                        EmptyView()
                        ShareModeView(viewModel: viewModel)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedMode)
            }
            .navigationTitle("Operaciones QR")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                viewModel.requestCameraPermission()
            }
            .fullScreenCover(isPresented: $viewModel.showSuccessScreen) {
                TransactionSuccessView(viewModel: viewModel)
            }
        }
    }
}

