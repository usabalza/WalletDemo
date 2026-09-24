//
//  TransactionCell.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct TransactionCell: View {
    var transaction: PersistentTransaction
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                switch transaction.tag {
                case .qrPayment, .p2pSent:
                    Image(systemName: "arrow.down.left")
                        .foregroundStyle(Color.red)
                case .qrRecharge, .p2pReceived:
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(Color.green)
                    
                case .all:
                    EmptyView()
                }
                VStack(alignment: .leading) {
                    Text(transaction.date.toShortString())
                        .font(.caption)
                    Text(transaction.tagRaw)
                }
                
                Spacer()
                
                Text("\(transaction.tag == .qrRecharge || transaction.tag == .p2pReceived ? "+" : "-") \(transaction.amount.toCurrency())")
                    .fontWeight(.bold)
            }
        }
        .padding(16)
    }
}
