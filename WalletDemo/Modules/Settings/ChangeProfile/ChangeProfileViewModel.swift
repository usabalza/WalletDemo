//
//  ChangeProfileViewModel.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import SwiftData

@Observable
class ChangeProfileViewModel {
    // Campos mutables que se enlazarán a los TextField de la UI
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var birthDate: String = ""
    var gender: String = "Masculino"
    var documentType: String = "DNI"
    var documentNumber: String = ""
    
    var isLoading: Bool = false
    var isSuccessActive: Bool = false
    
    /// Carga los datos actuales guardados en el disco dentro de los campos mutables de la UI
    func loadCurrentUserData(user: UserSession) {
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.birthDate = user.birthDate
        self.gender = user.gender
        self.documentType = user.documentType
        self.documentNumber = user.documentNumber
    }
    
    /// Persiste los cambios en el disco SQLite simulando los tiempos de espera de la API (HIG)
    @MainActor
    func updateProfileInStorage(context: ModelContext, user: UserSession) async {
        self.isLoading = true
        
        // Simulación de latencia de red bancaria central
        try? await Task.sleep(for: .seconds(1.2))
        
        // Mutamos el objeto persistente real directamente
        user.firstName = self.firstName
        user.lastName = self.lastName
        user.email = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        user.phoneNumber = self.phoneNumber
        user.birthDate = self.birthDate
        user.gender = self.gender
        user.documentType = self.documentType
        user.documentNumber = self.documentNumber
        
        // Guardamos los cambios en el disco SQLite
        try? context.save()
        
        // Activamos la bandera para levantar la pantalla de éxito universal
        withAnimation {
            self.isSuccessActive = true
        }
        
        self.isLoading = false
    }
}

