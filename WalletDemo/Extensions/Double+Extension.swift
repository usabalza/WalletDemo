//
//  Double+Extension.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import Foundation

extension Double {
    func toCurrency(code: String = "USD") -> String {
        return self.formatted(.currency(code: code))
    }
}