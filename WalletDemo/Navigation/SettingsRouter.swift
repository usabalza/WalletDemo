//
//  SettingsRouter.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import Observation

@Observable
class SettingsRouter {
    var path = NavigationPath()
    var activeSheet: SettingsSheet?
    
    public func push(to destination: SettingsDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ sheet: SettingsSheet) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}

enum SettingsDestination: Hashable {
    case editProfile
    case changePIN
    case changePassword
    case termsAndConditions
    case aboutMe
}

enum SettingsSheet: Identifiable, Hashable {
    case terms
    case privacy
    
    var id: String {
        switch self {
        case .terms:
            return "terms"
        case .privacy:
            return "privacy"
            
        }
    }
}
