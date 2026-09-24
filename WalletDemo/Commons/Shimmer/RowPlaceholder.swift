//
//  RowPlaceholder.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct RowPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundStyle(Color(.systemGray4))
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 12)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 140, height: 18)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray4))
                .frame(width: 100, height: 24)
            
        }
        .padding(16)
        .shimmer()
    }
}
