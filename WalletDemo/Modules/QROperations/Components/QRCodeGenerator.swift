//
//  QRCodeGenerator.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    private static let context = CIContext()
    private static let filter = CIFilter.qrCodeGenerator()
    
    /// Genera una Image de SwiftUI nativa a partir de un String
    static func generate(from string: String) -> Image? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        // "H" establece el nivel de corrección de errores en Alto (High - 30% de daño soportado)
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Intentamos obtener la imagen de salida del filtro de CoreImage
        guard let outputImage = filter.outputImage else { return nil }
        
        // Convertimos la CIImage a una CGImage para poder procesarla en SwiftUI sin desenfoques
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            return Image(uiImage: uiImage)
        }
        
        return nil
    }
}
