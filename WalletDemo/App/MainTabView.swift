//
//  MainTabView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: WalletTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // TAB 1: INICIO & TRANSACCIONES
            HomeView()
                .tabItem {
                    Label(
                        WalletTab.home.title,
                        systemImage: WalletTab.home.icon
                    )
                }
                .tag(WalletTab.home)
            
            // TAB 2: OPERACIONES QR (HÍBRIDO)
            QROperationsView()
                .tabItem {
                    Label(
                        WalletTab.qrOperations.title,
                        systemImage: WalletTab.qrOperations.icon
                    )
                }
                .tag(WalletTab.qrOperations)
            
            // TAB 3: CONTACTOS P2P
            P2PListView()
                .tabItem {
                    Label(WalletTab.p2p.title, systemImage: WalletTab.p2p.icon)
                }
                .tag(WalletTab.p2p)
            
            // TAB 4: CONFIGURACIONES
            SettingsView()
                .tabItem {
                    Label(
                        WalletTab.settings.title,
                        systemImage: WalletTab.settings.icon
                    )
                }
                .tag(WalletTab.settings)
        }
        .tint(.accentColor) // Color de énfasis global para la app
    }
}
