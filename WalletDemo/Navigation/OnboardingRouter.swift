//
//  OnboardingRouter.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import Observation

@Observable
class OnboardingRouter {
    var path = NavigationPath()
    var activeSheet: OnboardingSheet?
    
    public func push(to destination: OnboardingDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ sheet: OnboardingSheet) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}

enum OnboardingDestination: Hashable {
    case email
    case phone
    case password(recovery: Bool)
    case userData
    case otpEmail(recovery: Bool)
    case otpPhone
    case confirmationSuccess(title: String, subtitle: String)
    case confirmationFailure(title: String, subtitle: String)
}

enum OnboardingSheet: Identifiable, Hashable {
    case webView(url: String)
    
    var id: String {
        switch self {
        case .webView(let url):
            return "webview-\(url)"
        }
    }
}
