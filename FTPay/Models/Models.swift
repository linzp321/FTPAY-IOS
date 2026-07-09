import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let merchantId: String?
    let terminalId: String?
    let serialNumber: String?

    init(id: String = UUID().uuidString, email: String, merchantId: String? = nil, terminalId: String? = nil, serialNumber: String? = nil) {
        self.id = id
        self.email = email
        self.merchantId = merchantId
        self.terminalId = terminalId
        self.serialNumber = serialNumber
    }
}

// MARK: - Transaction
struct Transaction: Codable, Identifiable {
    let id: String
    let cardNumber: String       // e.g. "6226 **** **** 5981"
    let cardLabel: String        // e.g. "(000002)"
    let timestamp: Date
    let amount: Double
    let currency: String
    let status: TransactionStatus

    enum TransactionStatus: String, Codable {
        case approved = "APPROVED"
        case declined = "DECLINED"
        case pending = "PENDING"
    }

    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: timestamp)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: timestamp)
    }
}

// MARK: - MerchantInfo
struct MerchantInfo: Codable {
    let merchantId: String
    let terminalId: String
    let serialNumber: String
    let merchantName: String
    let totalCount: Int
    let totalCollections: Double
}

// MARK: - API Binding
struct APIBindingRequest: Codable {
    let merchantId: String
    let apiKey: String
    let domain: String
}

struct APIBindingResponse: Codable {
    let success: Bool
    let message: String
    let merchantInfo: MerchantInfo?
}

// MARK: - Purchase
struct PurchaseRequest: Codable {
    let amount: Double
    let currency: String
    let merchantId: String
    let terminalId: String
}

struct PurchaseResponse: Codable {
    let success: Bool
    let message: String
    let transactionId: String?
    let transaction: Transaction?
}

// MARK: - History Filter
enum HistoryFilter: String, CaseIterable {
    case year = "Year"
    case week = "Week"
    case month = "Month"

    var displayName: String { rawValue }
}

// MARK: - Sample Data
extension Transaction {
    static let sampleTransactions: [Transaction] = [
        Transaction(
            id: "TXN001",
            cardNumber: "6226 **** **** 5981",
            cardLabel: "(000002)",
            timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
            amount: 12.50,
            currency: "USD",
            status: .approved
        ),
        Transaction(
            id: "TXN002",
            cardNumber: "4556 **** **** 1234",
            cardLabel: "(000003)",
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            amount: 55.00,
            currency: "USD",
            status: .approved
        ),
        Transaction(
            id: "TXN003",
            cardNumber: "5412 **** **** 9876",
            cardLabel: "(000001)",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            amount: 8.75,
            currency: "USD",
            status: .declined
        ),
        Transaction(
            id: "TXN004",
            cardNumber: "3782 **** **** 5544",
            cardLabel: "(000004)",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            amount: 120.00,
            currency: "USD",
            status: .approved
        ),
        Transaction(
            id: "TXN005",
            cardNumber: "6011 **** **** 3344",
            cardLabel: "(000005)",
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            amount: 0.55,
            currency: "USD",
            status: .approved
        )
    ]
}
