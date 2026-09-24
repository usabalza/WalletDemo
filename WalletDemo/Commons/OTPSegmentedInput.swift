//
//  OTPSegmentedInput.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct OTPSegmentedInput: View {
    let codeLength: Int
    @Binding var otpCode: String // Sincronizado directamente con el String del ViewModel
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // TextField oculto conectado directamente al estado del ViewModel
            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
            
            // Cuadros segmentados de lectura fluida
            HStack(spacing: 12) {
                ForEach(0..<codeLength, id: \.self) { index in
                    let char = getCharacter(at: index)
                    let isCurrentField = otpCode.count == index
                    
                    Text(char)
                        .font(.title.bold())
                        .frame(width: 45, height: 55)
                        .multilineTextAlignment(.center)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused && isCurrentField ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                        )
                }
            }
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: otpCode) { _, newValue in
            if newValue.isEmpty {
                isFocused = false // Quita el foco un instante
                
                // Devuelve el foco en el siguiente ciclo de renderizado de la UI
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
    }
    
    // Extrae el carácter de la cadena de texto de forma segura para pintar la UI
    private func getCharacter(at index: Int) -> String {
        guard index < otpCode.count else { return "" }
        let stringIndex = otpCode.index(otpCode.startIndex, offsetBy: index)
        return String(otpCode[stringIndex])
    }
}
