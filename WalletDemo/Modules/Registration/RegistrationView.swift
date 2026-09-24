//
//  RegistrationView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI

enum RegDestination: Hashable {
    case emailOTP
    case phoneInput
    case phoneOTP
    case passwordInput
    case personalDataForm
}

struct RegistrationView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var viewModel = RegistrationViewModel()
    @State var router = RegistrationRouter()
    @State private var currentPage = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                HStack {
                    Spacer()
                    Button("Omitir") {
                        router.push(to: .email)
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        title: "Tu Wallet Digital",
                        description: "Gestiona tus tarjetas físicas y virtuales desde un solo lugar seguro.",
                        imageName: "creditcard.and.123"
                    ).tag(0)
                    
                    OnboardingPageView(
                        title: "Pagos Rápidos con QR",
                        description: "Escanea y comparte códigos QR para realizar transacciones en segundos.",
                        imageName: "qrcode.viewfinder"
                    ).tag(1)
                    
                    OnboardingPageView(
                        title: "Transferencias P2P",
                        description: "Envía dinero a tus amigos y familiares al instante y sin comisiones.",
                        imageName: "person.2.fill"
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button {
                    if currentPage < 2 {
                        withAnimation { currentPage += 1 }
                    } else {
                        // appStateManager.completeOnboarding()
                        router.push(to: .email)
                    }
                } label: {
                    Text(currentPage == 2 ? "Comenzar" : "Siguiente")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                Button {
                    appStateManager.navigateToLogin()
                } label: {
                    Text("Ya tengo una cuenta")
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                        .padding()
                }
            }
            .background(Color(.systemBackground))
            .navigationDestination(for: RegistrationDestination.self) { destination in
                switch destination {
                case .email:
                    RegEmailInputView()
                case .otpEmail:
                    RegOTPValidationView(otpType: .email)
                case .phone:
                    RegPhoneInputView()
                case .otpPhone:
                    RegOTPValidationView(otpType: .phone)
                case .password:
                    RegPasswordInputView()
                case .userData:
                    RegPersonalDataFormView()
                }
            }
            .fullScreenCover(isPresented: $viewModel.isRegistrationComplete) {
                let successConfig = StatusFeedbackConfiguration(
                    status: .success,
                    title: "¡Cuenta Creada con Éxito!",
                    subtitle: "Bienvenido a tu Wallet. Tu identidad ha sido verificada correctamente y hemos generado tus credenciales de acceso seguro.",
                    systemIcon: "person.crop.circle.badge.checkmark", // Icono personalizado de perfil aprobado
                    buttonTitle: "Ir a mi Billetera"
                )
                
                UniversalFeedbackView(config: successConfig) {
                    viewModel.isRegistrationComplete = false
                    appStateManager.navigateToLogin() // 🎯 Redirección HIG al Login
                }
            }
        }
        .environment(router)
        .environment(viewModel)
        
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .padding()
            
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
