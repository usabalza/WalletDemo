# 💳 Wallet demo, an Advanced iOS Fintech Wallet — Clean Architecture, SwiftUI & SwiftData

[![iOS 17.0+](https://shields.io)](https://apple.com)
[![Swift 5.10](https://shields.io)](https://swift.org)
[![SwiftData](https://shields.io)](https://apple.com)
[![SwiftCharts](https://shields.io)](https://apple.com)

A high-performance, native digital wallet (Fintech) application developed in **SwiftUI** for iOS 17+. The project implements a modular **Feature-Driven MVVM Architecture**, decoupled navigation engines (Push/Sheet Coordinators), hybrid biometric authentication, and an encrypted local relational persistence system using **SwiftData**.

The application's layout and tactile interactions have been built strictly adhering to the **Apple Human Interface Guidelines (HIG)**, ensuring premium usability, universal accessibility, and adaptive hardware haptic feedback.

---

## 🏛️ Architecture and Design Patterns

The project rejects traditional highly-coupled hierarchies and adopts a modern **Feature-Driven Architecture** combined with up-to-date SwiftUI patterns:

```text

┌────────────────────────────────────────────────────────────────────────┐
│                              RootContentView                           │
│                     (Exclusión Mutua de Flujos Generales)              │
└─────────────────────────────────┬──────────────────────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
┌─────────────────┐      ┌─────────────────┐      ┌──────────────────┐
│ Onboarding Flow │      │   Login Flow    │      │  Main App (Tabs) │
│   (Bienvenida)  │      │ (Seguridad/PIN) │      │  (Dashboard Core)│
└─────────────────┘      └─────────────────┘      └──────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  ▼
                     ┌───────────────────────────┐
                     │     AppStateManager       │
                     │ (Persistencia SwiftData)  │
                     └───────────────────────────┘

```

### 1. Environment Injection (`@Environment`) vs Constructor Parameters
* **Sequential Multi-step Flows (Wizards):** Within the Registration module (6 successive screens), a **single centralized ViewModel injected via the view environment (`.environment`)** is used. This completely eliminates *Parameter Tunneling*, optimizes RAM usage, and allows data to accumulate in a clean, progressive manner until the final API submission.
* **Atomic Components:** Isolated, reusable views (such as `CardView` or `TransactionRow`) receive explicit dependencies through their constructors, maximizing immutability and rendering speeds in Xcode Previews (`#Preview`).

### 2. Decoupled Programmatic Routing
The use of implicit `NavigationLink` markers hidden deep inside the view tree has been eradicated. Instead, navigation is 100% programmatically controlled via an observable `NavigationRouter` class bound directly to the iOS 17 native `NavigationPath`.
* **Push Navigation:** Utilized for deep flows that maintain a clear linear hierarchy (Registration wizard, transactional history, credentials management).
* **Sheet/Cover Presentation:** Utilized for sharp contextual workflows (Transaction receipts, QR payment dialogs). Upon workflow completion, the active router dispatches a coordinated `popToRoot()` or `dismissSheet()` call to prevent memory leaks or stranded overlay states.

### 3. Boot Flow Safeguards (Mutual Exclusion)
To mitigate visual bugs during app launches (where the main dashboard briefly rendered over the security keypad), the root coordinator `RootContentView` implements an explicit conditional `Group` with structural view IDs (`.id("flow_name")`). This forces SwiftUI to **completely purge inactive workflows from RAM** and draw the selected environment from scratch using asynchronous transitions.

---

## ⚡ Core Features & Technical Highlights

### 🔒 Bank-Grade Security Suite & Hybrid Login
* **Two-Layer Authentication:** A clear separation is maintained between remote validation (Email/Password verified against optimized queries in SwiftData) and daily quick local validation (4-digit PIN + FaceID/TouchID).
* **Tailored Tactile Keypad:** Built from custom circular buttons. The system captures numeric input using an invisible native `TextField` and dispatches a **horizontal shake animation (Shake Effect)** combined with a heavy hardware error haptic impulse (`.error`) if the validation fails.
* **Predictive Regex Validation:** The email entry fields and the secure password checklist evaluate text strings in real time using native regular expressions over fully normalized data (`.trimmedAndLowercased()`), filtering out broken formats or accidental white spaces.

### 📷 QR Operations & Pixel-Perfect CoreImage
* **Dynamic QR Code Generation:** Utilizes the built-in CoreImage filter `CIQRCodeGenerator`, locking error correction to High level ("H"). The SwiftUI `.interpolation(.none)` modifier is applied to disable pixel antialiasing, yielding sharp, high-contrast matrix barcodes that remain scannable under extreme glare conditions.
* **Hybrid Scanner Architecture:** Utilizing compile-time directives (`#if targetEnvironment(simulator)`), the application dynamically checks its host. On a Mac simulator, it renders an interactive testing override to inject mock transaction data payload. On a physical iPhone, it instantiates a native hardware capture session via `AVFoundation` bridged through a custom `UIViewRepresentable`.

### 📊 Financial Insights with SwiftCharts
A macro-level view of consumption trends is integrated through Apple’s native data visualization framework.
* Data bars utilize semantic gradients based on the main brand color (`Color.accentColor.gradient`), automatically highlighting only the highest peak of the 6-month historical dataset.
* Adheres to HIG principles by rendering minimalist background grids with dashed styling, simplifying Y-axis numeric labels to keep the dashboard clear and scannable.

### 💾 Relational Persistence via SwiftData
All business data (Cards, Movements, Profiles, and P2P Contacts) persists inside an encrypted local SQLite relational database within the app's secure sandbox.
* **Hardware Singleton Pattern:** To completely solve a well-known CoreData/SwiftData bug (`Persistent History has to be truncated due to entities being removed`), container initialization was centralized into a thread-safe static property (`SharedModelContainer.shared`). This prevents the `AppStateManager` and the `@main` window from opening conflicting concurrent channels against the same physical file on disk.
* **Cascade Delete Rules:** Models implement explicit relationships (`@Relationship(deleteRule: .cascade)`). When a user deletes a credit card from its contextual security menu, the system automatically purges all connected ledger transactions, keeping the phone clean of orphaned data.

---

## 🎨 Apple Human Interface Guidelines (HIG) Compliance

* **Semantic and Restrained Color Use:** Transaction amounts on the home feed are styled strictly using the standard primary font color (`.primary`), relying on explicit mathematical symbols (`+` or `-`) for financial category definition. This closely emulates the official *Apple Wallet* experience, avoiding visual clutter and ensuring an accessible contrast ratio approved for users with visual impairments.
* **Universal Feedback Infrastructure:** Integrated modern empty states via `ContentUnavailableView` (iOS 17). Unloaded panels smoothly guide users using dynamic SF Symbols animated via continuous layer pulsing (`.symbolEffect(.pulse)`).
* **Destructive Action Guards:** Before removing any payment method, a native confirmation modal is displayed. The confirming button automatically adopts a distinct red accent tint (`role: .destructive`), while the cancel alternative takes structural focus in bold (`role: .cancel`) to safeguard user data against accidental taps.

---

## 🚀 System Requirements

* **Xcode 15.0+**
* **Swift 5.9+**
* **iOS 17.0+** (Required for the native `@Observable` macro, SwiftCharts, and the SwiftData persistent context layer)
* **Physical Device:** Required exclusively for opening real camera video capture layers within the QR scanner module.

---

## 📂 Architecture Directory Tree
```text
WalletApp/
│
├── 🚀 Core/
│   ├── WalletApp.swift                 # Punto de entrada de la App (.modelContainer)
│   ├── RootContentView.swift           # Exclusión mutua de flujos (.onboarding, .login, .mainApp)
│   └── AppStateManager.swift           # Motor global de estado y Singleton de SwiftData
│
├── 💾 Data/
│   ├── Models/
│   │   ├── UserSession.swift           # @Model - Sesión, PIN, Biometría e Info de usuario
│   │   ├── PersistentCard.swift        # @Model - Tarjetas físicas/virtuales y gradientes
│   │   ├── PersistentTransaction.swift # @Model - Historial de movimientos relacionales
│   │   └── PersistentContact.swift     # @Model - Contactos P2P y favoritos
│   │
│   └── Shared/
│       └── SharedModelContainer.swift  # Singleton de hardware para evitar corrupciones de CoreData
│
├── 🎛️ Navigation/
│   ├── NavigationRouter.swift          # Clase genérica @Observable para rutas Push
│   └── HomeNavigationRouter.swift      # Router especializado con control de Push + Sheets modales
│
├── 📦 Modules/
│   ├── 🍏 Onboarding/
│   │   ├── OnboardingContainerView.swift# Carrusel de introducción y accesos directos
│   │   └── OnboardingSubViews.swift    # Pantallas estáticas del carrusel de bienvenida
│   │
│   ├── 🔑 Registration/
│   │   ├── RegistrationFlowContainer.swift # Orquestador Push del Wizard de Registro
│   │   ├── RegistrationViewModel.swift # ViewModel único inyectado por @Environment
│   │   ├── RegEmailInputView.swift     # Paso 1: Email con validación estricta Regex
│   │   ├── RegOTPValidationView.swift  # Pasos 2 y 4: Entrada segmentada sin botón de submit
│   │   ├── RegPhoneInputView.swift     # Paso 3: Celular con menú desplegable de banderas
│   │   ├── RegPasswordInputView.swift  # Paso 5: Inputs seguros con checklist de requerimientos
│   │   └── RegPersonalDataFormView.swift# Paso 6: Formulario final con inyección a SwiftData
│   │
│   ├── 🔒 Login/
│   │   ├── LoginFlowContainer.swift    # Orquestador híbrido (Primer login vs Acceso cotidiano)
│   │   ├── LoginViewModel.swift        # ViewModel con autenticación encriptada asíncrona
│   │   ├── LoginTraditionalView.swift  # Login por email/clave con spinner e inline validation
│   │   ├── LoginBiometricsSetupView.swift # Enrolamiento inicial rápido de FaceID
│   │   ├── LoginPINSetupView.swift     # Creación y confirmación del PIN inicial
│   │   └── LoginRegularAccessView.swift# Pantalla diaria de bloqueo con autodisparo biométrico
│   │
│   ├── 🏠 Home/
│   │   ├── HomeWalletView.swift        # Dashboard principal (Saludo, carrusel y actividad)
│   │   ├── WalletViewModel.swift       # Controller de persistencia de tarjetas y data de SwiftCharts
│   │   ├── AllTransactionsView.swift   # Historial completo LazyVStack agrupado por fecha
│   │   └── AllTransactionsViewModel.swift # ViewModel de ordenamiento y filtrado por tags
│   │
│   ├── 📷 QROperations/
│   │   ├── TabQRContainer.swift        # Selector segmentado unificado (.scan vs .share)
│   │   ├── QROperationsViewModel.swift # Controller de hardware de cámara y cobros QR
│   │   ├── ScannerModeView.swift       # Lógica híbrida: botón simulador / AVFoundation real
│   │   ├── CameraPreviewView.swift     # UIViewRepresentable del visor nativo de captura de video
│   │   ├── ShareModeView.swift         # Generador de códigos QR nítidos vía CoreImage
│   │   └── PaymentConfirmationSheet.swift # Formulario de cobro con teclado táctil integrado
│   │
│   ├── ✈️ P2PContacts/
│   │   ├── TabP2PContainer.swift       # Listado P2P LazyVStack con menús contextuales
│   │   └── P2PContactViewModel.swift   # ViewModel transaccional asíncrono enlazado a SwiftData
│   │
│   └── ⚙️ Settings/
│       ├── TabSettingsContainer.swift  # Listado estático .insetGrouped de configuración
│       ├── SettingsViewModel.swift     # Controller de preferencias de hardware (UserDefaults)
│       ├── ChangePINView.swift         # Módulo de cambio de PIN secuencial adaptativo
│       ├── ChangePINViewModel.swift    # Validaciones del wizard de PIN con efectos de error
│       ├── EditProfileView.swift       # Formulario con precarga HIG automática de datos actuales
│       ├── EditProfileViewModel.swift  # Actualización del registro mutable del usuario
│       ├── ChangePasswordView.swift    # Actualización segura de la clave del Keychain de Apple
│       └── ChangePasswordViewModel.swift# Validaciones lógicas de la nueva clave de acceso
│
└── 🎨 SharedComponents/
    ├── CardView.swift                  # Componente de la Tarjeta con Ojo de privacidad y Menú
    ├── TransactionRow.swift            # Celda de movimiento con colores semánticos discretos (HIG)
    ├── WalletAnalyticsCard.swift       # Gráfico analítico de barras nativo usando SwiftCharts
    ├── UniversalFeedbackView.swift     # Interfaz universal animada para Éxitos y Fallos
    ├── PINVerificationView.swift       # Cover de teclado numérico táctil con feedback háptico
    └── Extensions/
        ├── Color+Hex.swift             # Extensión para mapear gradientes bancarios vía Hex
        └── String+Trim.swift           # Extensión de normalización de cadenas para búsquedas
```
