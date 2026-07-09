import Foundation
import Combine

final class APIService {
    static let shared = APIService()

    private var baseURL: String {
        return UserDefaults.standard.string(forKey: "apiDomain") ?? "https://impcoden.ftsafe.com:8443"
    }

    private init() {}

    // MARK: - Login
    func login(email: String, password: String) async throws -> User {
        // Simulated login — replace with real API call in production
        try await Task.sleep(nanoseconds: 800_000_000)

        guard !email.isEmpty, !password.isEmpty else {
            throw APIError.invalidCredentials
        }

        return User(
            email: email,
            merchantId: "MID-" + String(email.prefix(6)).uppercased(),
            terminalId: "TERM-001",
            serialNumber: "SN-" + UUID().uuidString.prefix(8).uppercased()
        )
    }

    // MARK: - Fetch Merchant Info
    func fetchMerchantInfo(apiKey: String) async throws -> MerchantInfo {
        try await Task.sleep(nanoseconds: 600_000_000)

        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }

        return MerchantInfo(
            merchantId: "MID-\(apiKey.prefix(6).uppercased())",
            terminalId: "TERM-\(Int.random(in: 100...999))",
            serialNumber: "SN-\(UUID().uuidString.prefix(8).uppercased())",
            merchantName: "FT Restaurant",
            totalCount: Int.random(in: 50...500),
            totalCollections: Double(Int.random(in: 1000...50000)) / 100.0
        )
    }

    // MARK: - Bind API Key
    func bindAPIKey(request: APIBindingRequest) async throws -> APIBindingResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        guard !request.apiKey.isEmpty, !request.merchantId.isEmpty else {
            throw APIError.missingAPIKey
        }

        let merchantInfo = MerchantInfo(
            merchantId: request.merchantId,
            terminalId: "TERM-\(Int.random(in: 100...999))",
            serialNumber: "SN-\(UUID().uuidString.prefix(8).uppercased())",
            merchantName: "FT Restaurant",
            totalCount: 0,
            totalCollections: 0.0
        )

        return APIBindingResponse(
            success: true,
            message: "API Key bound successfully",
            merchantInfo: merchantInfo
        )
    }

    // MARK: - Fetch Transactions
    func fetchTransactions(filter: HistoryFilter) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 500_000_000)

        // Return sample transactions filtered by date
        let allTransactions = Transaction.sampleTransactions
        let calendar = Calendar.current

        switch filter {
        case .week:
            return allTransactions.filter { calendar.isDate($0.timestamp, equalTo: Date(), toGranularity: .weekOfYear) }
        case .month:
            return allTransactions.filter { calendar.isDate($0.timestamp, equalTo: Date(), toGranularity: .month) }
        case .year:
            return allTransactions.filter { calendar.isDate($0.timestamp, equalTo: Date(), toGranularity: .year) }
        }
    }

    // MARK: - Process Payment
    func processPayment(request: PurchaseRequest) async throws -> PurchaseResponse {
        try await Task.sleep(nanoseconds: 1_500_000_000)

        guard request.amount > 0 else {
            throw APIError.invalidAmount
        }

        let transaction = Transaction(
            id: UUID().uuidString,
            cardNumber: "**** **** **** \(Int.random(in: 1000...9999))",
            cardLabel: "(\(String(format: "%06d", Int.random(in: 1...999999))))",
            timestamp: Date(),
            amount: request.amount,
            currency: request.currency,
            status: .approved
        )

        return PurchaseResponse(
            success: true,
            message: "Transaction approved",
            transactionId: transaction.id,
            transaction: transaction
        )
    }

    // MARK: - Update Settings
    func updateSettings(primaryColor: String, secondaryColor: String, domain: String, language: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // Save locally
        UserDefaults.standard.set(primaryColor, forKey: "primaryColor")
        UserDefaults.standard.set(secondaryColor, forKey: "secondaryColor")
        UserDefaults.standard.set(domain, forKey: "apiDomain")
        UserDefaults.standard.set(language, forKey: "language")
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidCredentials
    case missingAPIKey
    case invalidAmount
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .missingAPIKey:
            return "API Key is required"
        case .invalidAmount:
            return "Invalid payment amount"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return message
        }
    }
}
