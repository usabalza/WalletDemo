//
//  AboutMeView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

struct AboutMeView: View {
    var body: some View {
        VStack {
            Image("uziel-sabalza")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4)
                )
                .shadow(radius: 7)
                .padding(20)
            
            Text("Uziel Sabalza")
                .font(.title)
                .fontWeight(.bold)
                .padding(20)
            
            Form {
                Section(header: Text("GitHub")) {
                    Text("https://github.com/usabalza")
                }
                Section(header: Text("LinkedIn")) {
                    Text("https://www.linkedin.com/in/uziel-sabalza-a535b6214")
                }
            }
            
            
            
        }
        .navigationTitle("Acerca de mí")
        
    }
}
