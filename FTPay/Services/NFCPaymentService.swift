import Foundation
import CoreNFC

final class NFCPaymentService: NSObject, ObservableObject {
    static let shared = NFCPaymentService()

    @Published var isNFCAvailable: Bool = NFCNDEFReaderSession.readingAvailable
    @Published var isProcessing: Bool = false
    @Published var paymentState: PaymentState = .idle

    enum PaymentState {
        case idle
        case waitingForCard
        case cardDetected
        case processing
        case success(Transaction)
        case failed(String)
    }

    private var session: NFCNDEFReaderSession?
    private var paymentContinuation: CheckedContinuation<PurchaseResponse, Error>?

    override init() {
        super.init()
    }

    // MARK: - Check Availability
    func checkAvailability() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    // MARK: - Start NFC Payment
    func startPayment(amount: Double, currency: String = "USD") async throws -> PurchaseResponse {
        guard isNFCAvailable else {
            throw NFCErrors.notAvailable
        }

        await MainActor.run {
            self.isProcessing = true
            self.paymentState = .waitingForCard
        }

        // Simulate NFC card read and payment processing
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let transaction = Transaction(
            id: UUID().uuidString,
            cardNumber: "**** **** **** \(Int.random(in: 1000...9999))",
            cardLabel: "(\(String(format: "%06d", Int.random(in: 1...999999))))",
            timestamp: Date(),
            amount: amount,
            currency: currency,
            status: .approved
        )

        await MainActor.run {
            self.isProcessing = false
            self.paymentState = .success(transaction)
        }

        return PurchaseResponse(
            success: true,
            message: "Transaction approved",
            transactionId: transaction.id,
            transaction: transaction
        )
    }

    // MARK: - Cancel Payment
    func cancelPayment() {
        session?.invalidate()
        session = nil
        isProcessing = false
        paymentState = .idle
    }

    // MARK: - Simulate Payment (for development/simulator)
    func simulatePayment(amount: Double, currency: String = "USD") async -> PurchaseResponse {
        await MainActor.run {
            self.isProcessing = true
            self.paymentState = .waitingForCard
        }

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        let transaction = Transaction(
            id: UUID().uuidString,
            cardNumber: "**** **** **** \(Int.random(in: 1000...9999))",
            cardLabel: "(\(String(format: "%06d", Int.random(in: 1...999999))))",
            timestamp: Date(),
            amount: amount,
            currency: currency,
            status: .approved
        )

        await MainActor.run {
            self.isProcessing = false
            self.paymentState = .success(transaction)
        }

        return PurchaseResponse(
            success: true,
            message: "Transaction approved (Simulated)",
            transactionId: transaction.id,
            transaction: transaction
        )
    }

    // MARK: - Reset State
    func reset() {
        isProcessing = false
        paymentState = .idle
    }
}

// MARK: - NFC Errors
enum NFCErrors: LocalizedError {
    case notAvailable
    case notSupported
    case sessionInvalid
    case readError

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "NFC is not available on this device"
        case .notSupported:
            return "NFC is not supported"
        case .sessionInvalid:
            return "NFC session is invalid"
        case .readError:
            return "Failed to read NFC card"
        }
    }
}
