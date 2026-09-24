//
//  String+Extension.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import Foundation

extension String {
    /// Convierte un String en formato ISO8601 a un objeto Date (iOS 15+)
    func toDateFromISO8601() -> Date? {
        return try? Date(self, strategy: .iso8601)
    }
    
    func trimmedAndLowercased() -> String {
        self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
