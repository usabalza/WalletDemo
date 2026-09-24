//
//  RegistrationRouter.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import Observation

@Observable
class RegistrationRouter {
    var path = NavigationPath()
    var activeSheet: RegistrationSheet?
    
    public func push(to destination: RegistrationDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ sheet: RegistrationSheet) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}

enum RegistrationDestination: Hashable {
    case email
    case password
    case otpEmail
    case otpPhone
    case phone
    case userData
}

enum RegistrationSheet: Identifiable, Hashable {
    case terms
    case privacy
    
    // Requerido por el protocolo Identifiable para que SwiftUI controle el ciclo de vida del Sheet
    var id: String {
        switch self {
        case .terms:
            return "terms"
        case .privacy:
            return "privacy"
            
        }
    }
}
