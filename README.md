# 📱 WalletDemo, an Advanced iOS Fintech Wallet — Clean Architecture, SwiftUI & SwiftData

[![Swift](https://shields.io)](https://swift.org)
[![iOS](https://shields.io)](https://apple.com)
[![SwiftUI](https://shields.io)](https://apple.com)
[![SwiftData](https://shields.io)](https://apple.com)
[![Architecture](https://shields.io)]()

### 📄 Description
**WalletDemo** is a native iOS application simulating a fully local digital wallet ecosystem. The project was built using a highly modular and decoupled approach, eliminating external API dependencies by leveraging **SwiftData** for all persistent data storage and local relationship management. 

This repository showcases advanced iOS development practices, featuring modern navigation workflows, native biometric security, structured concurrency, and elegant data visualization using Apple's official frameworks.

---

### 📸 UI/UX Preview

| Onboarding & Login | Dashboard & Analytics | QR Payments            | P2P Contacts           |
| ------------------ | --------------------- | ---------------------- | ---------------------- |
| <img width="220" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-24 at 13 46 51" src="https://github.com/user-attachments/assets/2cf62b7f-9926-44c5-b697-dcf951ee491d" />| <img width="220" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-24 at 13 48 59" src="https://github.com/user-attachments/assets/3075678e-69bd-45fd-8b9d-df66cee5d194" /> | <img width="220" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-24 at 13 50 09" src="https://github.com/user-attachments/assets/1ec70230-8c66-4f10-b860-7bc82fd0353d" /> | <img width="220" alt="Simulator Screenshot - iPhone 17 Pro - 2026-09-24 at 13 51 06" src="https://github.com/user-attachments/assets/d3a32d5b-af05-4271-bef3-96ceb9f7bad6" /> |

---

### ⚙️ Core Architecture & Key Concepts

*   **MVVM Architecture:** Strict separation of concerns. ViewModels manage UI state and business logic utilizing iOS 17's new `@Observable` macro.
*   **Decoupled Navigation Engine:** A centralized, clean navigation system routing complex user flows through `NavigationStack`, `Sheets`, and `FullScreenCover` without coupling logic inside SwiftUI views.
*   **Modern Concurrency:** Full integration of `async/await` to simulate asynchronous work during intensive operations such as transaction processing and simulated account setups.
*   **Native Persistence:** Built with **SwiftData** to seamlessly handle local database relationships between users, payment cards, transactions, and contacts.

---

### 📦 Application Modules

#### 🚀 1. Onboarding & Hybrid Authentication
*   **Local Registration:** Account creation and initial user profile storage managed via SwiftData.
*   **Security Layer:** Hybrid login experience blending biometric authentication (Face ID/Touch ID via `LocalAuthentication`) with a secure fallback 
PIN/password.

#### 💳 2. Main Dashboard (Home)
*   **Card Management:** Simulation of physical and virtual credit/debit card provisioning, customization, and deletion.
*   **Transaction Ledger:** Dynamic, real-time transaction postings updated onto a history feed.
*   **Visual Metrics:** A comprehensive financial overview rendered natively through interactive **SwiftCharts**.

#### 🔍 3. QR Payment Module
*   **Scanner Subsystem:** Camera-based scanner simulation to process immediate mock point-of-sale payments.
*   **P2P QR Code:** Native generation and sharing of the user's specific QR code to receive inbound transactions.

#### 👥 4. P2P Contacts & Transfers
*   **Financial Directory:** Local contact book to add, update, and manage trusted peers.
*   **Instant Transfers:** Seamless Peer-to-Peer (P2P) money transfer flow backed by local SwiftData models.

#### ⚙️ 5. Settings & Profile Management
*   Control panel allowing users to modify personal profiles, update passwords/PINs, and toggle biometric permissions on or off.

---

### 🧪 Unit Testing
The project features a comprehensive suite of **Unit Tests built on Swift Testing** (Apple's modern testing framework).
*   Validation of core ViewModel business logic.
*   Data integrity testing for SwiftData container insertions and transaction updates.

To execute the test suite, open Xcode and hit `CMD + U`.

---

### 🛠️ Tech Stack

*   **Language:** Swift 5.10+ (`async/await`)
*   **UI Framework:** SwiftUI (iOS 17.0+ Minimum Target)
*   **Data Visualization:** SwiftCharts
*   **Persistence Layer:** SwiftData
*   **Testing Framework:** Swift Testing

---

### 🚀 Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com
   ```
2. Navigate to the project root directory and launch it in Xcode:
   ```bash
   cd WalletDemo
   open WalletDemo.xcodeproj
   ```
3. Target an iOS simulator running **iOS 17.0** or higher.
4. Press `CMD + R` to build and run the application.

> 💡 *Tip: To test the biometric login workflow in the simulator, go to the top menu bar and select **Features -> Face ID -> Enrolled**.*

---

### 👨‍💻 Author

Developed by **Uziel Sabalza**
*   **LinkedIn:** Uziel Sabalza (https://linkedin.com/in/uziel-sabalza-a535b6214)
*   **Portfolio:** [Your Website](https://yourwebsite.com)
*   **Email:** uziel.sabalza.dev@gmail.com

