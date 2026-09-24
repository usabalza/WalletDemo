//
//  WalletAnalyticsCard.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//

import SwiftUI
import Charts // 👈 Framework oficial de Apple

struct WalletAnalyticsCard: View {
    let dataset: [ExpenseSummary]
    
    // Encontrarnos el mes con mayor gasto para destacarlo visualmente si es necesario
    private var maxExpense: Double {
        dataset.map { $0.totalAmount }.max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Cabecera de la Tarjeta Analítica
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis de Gastos")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Consolidado de los últimos 6 meses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chart.bar.xaxis")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            // 📊 MOTOR DE RENDERIZACIÓN SWIFTCHARTS (Nativo e HIG Compliant)
            Chart {
                ForEach(dataset) { item in
                    // BarMark dibuja barras verticales automáticamente
                    BarMark(
                        x: .value("Mes", item.monthName),
                        y: .value("Monto ($)", item.totalAmount)
                    )
                    // Color dinámico: La barra más alta toma el color de énfasis, las demás un tono sutil
                    .foregroundStyle(item.totalAmount == maxExpense ? Color.accentColor.gradient : Color.accentColor.opacity(0.4).gradient)
                    // Bordes suavizados para una estética moderna y premium
                    .cornerRadius(6)
                }
            }
            .frame(height: 160)
            // Configuración de los ejes y rejillas de fondo recomendadas por Apple
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(Color(.systemGray4))
                    // Simplificamos los números grandes (ej: 500 en lugar de 500.00)
                    if let doubleValue = value.as(Double.self) {
                        AxisValueLabel("$\(Int(doubleValue))")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}
