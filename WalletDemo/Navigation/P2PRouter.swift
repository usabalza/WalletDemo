//
//  P2PRouter.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import Observation

@Observable
class P2PRouter {
    var path = NavigationPath()
    //var activeSheet: HomeSheet?
    
    public func push(to destination: P2PDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

enum P2PDestination: Hashable {
    case addContactForm
}
