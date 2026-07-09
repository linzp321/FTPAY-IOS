import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var amountString: String = ""
    @State private var purchaseState: PurchaseState = .input
    @State private var currentTransaction: Transaction?
    @State private var isLoading: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let nfcService = NFCPaymentService.shared

    enum PurchaseState {
        case input
        case nfcPrompt
        case processing
        case success
        case failed
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar - Green
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding()
                .background(Color.green)

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Display Card
                        amountCard

                        // Custom Numeric Keypad
                        NumericKeypadView(
                            value: $amountString,
                            maxLength: 10,
                            onConfirm: handleConfirm,
                            onCancel: nil
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 24)
                }

                Spacer()
            }

            // NFC Prompt Overlay
            if purchaseState == .nfcPrompt {
                NFCPromptOverlay(
                    amount: currentAmount,
                    merchantName: "FT Restaurant",
                    onCancel: { purchaseState = .input },
                    onSimulate: handleSimulatePayment
                )
            }

            // Loading Overlay
            if purchaseState == .processing {
                LoadingOverlay(message: "Processing payment...")
            }

            // Success Overlay
            if purchaseState == .success {
                SuccessOverlay(
                    message: "Transaction Successful",
                    onDismiss: {
                        resetAndDismiss()
                    }
                )
            }

            // Error Alert
            if showError {
                errorAlert
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Amount Card
    private var amountCard: some View {
        VStack(spacing: 8) {
            Text("Amount")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(amountString.isEmpty ? "0.00" : amountString)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    // MARK: - Actions
    private var currentAmount: Double {
        Double(amountString) ?? 0.0
    }

    private func handleConfirm() {
        guard currentAmount > 0 else { return }
        purchaseState = .nfcPrompt
    }

    private func handleSimulatePayment() {
        purchaseState = .processing

        Task {
            do {
                let response = try await nfcService.simulatePayment(amount: currentAmount)
                await MainActor.run {
                    if response.success, let transaction = response.transaction {
                        currentTransaction = transaction
                        purchaseState = .success

                        // Update app statistics
                        appState.totalCount += 1
                        appState.totalCollections += transaction.amount
                        appState.recentTransactions.insert(transaction, at: 0)
                        if appState.recentTransactions.count > 5 {
                            appState.recentTransactions = Array(appState.recentTransactions.prefix(5))
                        }
                        appState.saveCredentials()
                    } else {
                        errorMessage = response.message
                        showError = true
                        purchaseState = .input
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    purchaseState = .input
                }
            }
        }
    }

    private func resetAndDismiss() {
        amountString = ""
        purchaseState = .input
        currentTransaction = nil
        nfcService.reset()
        dismiss()
    }

    private var errorAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                Button("OK") {
                    showError = false
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 100, height: 40)
                .background(Color.red)
                .cornerRadius(8)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

// MARK: - NFC Prompt Overlay
struct NFCPromptOverlay: View {
    let amount: Double
    let merchantName: String
    let onCancel: () -> Void
    let onSimulate: () -> Void

    var body: some View {
        ZStack {
            // Animated Background
            ParticleBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // NFC Icon with pulse animation
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .modifier(PulseModifier())

                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 100, height: 100)

                    Image(systemName: "wave.3.right")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }

                VStack(spacing: 8) {
                    Text("Tap here to pay")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("Pay to \(merchantName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text(String(format: "$%.2f", amount))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                // Simulate Button (for development)
                VStack(spacing: 12) {
                    Button(action: onSimulate) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Simulate Payment (Dev)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .opacity(isAnimating ? 0.3 : 0.6)
            .animation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

// MARK: - Particle Background
struct ParticleBackgroundView: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#0a1628")

                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.cyan.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<40).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.1...0.4)
            )
        }
    }
}
