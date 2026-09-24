//
//  PasswordRequirements.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import Foundation

struct PasswordRequirements {
    var hasMinLength: Bool = false
    var hasUppercase: Bool = false
    var hasLowercase: Bool = false
    var hasNumber: Bool = false
    var hasSpecialChar: Bool = false
    
    var isValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar
    }
}