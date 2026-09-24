//
//  Date+Extension.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import Foundation

extension Date {
    /// Convierte un Date a un String en formato corto según la región del usuario (iOS 15+)
    func toShortString() -> String {
        return self.formatted(date: .numeric, time: .omitted)
    }
}
