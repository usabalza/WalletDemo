//
//  HomeRouter.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import Observation

@Observable
class HomeRouter {
    var path = NavigationPath()
    var activeSheet: HomeSheet?
    
    public func push(to destination: HomeDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ sheet: HomeSheet) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}

enum HomeDestination: Hashable {
    case allTransactions
    case addNewCard
}

enum HomeSheet: Identifiable, Hashable {
    case transactionDetails(PersistentTransaction)
    
    var id: String {
        switch self {
        case .transactionDetails(let transaction):
            return "detail-\(transaction.id.uuidString)"
        }
    }
}
