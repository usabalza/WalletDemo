//
//  UserSession.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import Foundation
import SwiftData

@Model
final class UserSession {
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var gender: String
    var password: String
    var documentType: String
    var documentNumber: String
    var birthDate: String
    var savedPIN: String?
    
    init(firstName: String, lastName: String, email: String, phoneNumber: String, gender: String, password: String, documentType: String, documentNumber: String, birthDate: String, savedPIN: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.password = password
        self.documentType = documentType
        self.documentNumber = documentNumber
        self.birthDate = birthDate
        self.savedPIN = savedPIN
    }
}
