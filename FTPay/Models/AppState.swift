import SwiftUI
import Combine

final class AppState: ObservableObject {
    // MARK: - Login
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?

    // MARK: - Merchant Info
    @Published var merchantId: String = ""
    @Published var terminalId: String = ""
    @Published var serialNumber: String = ""
    @Published var apiKey: String = ""

    // MARK: - Statistics
    @Published var totalCount: Int = 0
    @Published var totalCollections: Double = 0.0
    @Published var recentTransactions: [Transaction] = []

    // MARK: - Settings
    @Published var primaryColor: Color = Color(hex: "#007AFF")
    @Published var secondaryColor: Color = Color(hex: "#5856D6")
    @Published var apiDomain: String = "https://impcoden.ftsafe.com:8443"
    @Published var language: String = "English"

    // MARK: - Navigation
    @Published var showDrawer: Bool = false
    @Published var showPasswordVerify: Bool = false
    @Published var pendingNavigation: NavigationTarget?

    enum NavigationTarget {
        case settings
        case bindAPIKey
        case purchase
        case history
    }

    // MARK: - User Defaults Keys
    private let userDefaults = UserDefaults.standard
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let merchantId = "merchantId"
        static let terminalId = "terminalId"
        static let serialNumber = "serialNumber"
        static let apiKey = "apiKey"
        static let apiDomain = "apiDomain"
        static let primaryColor = "primaryColor"
        static let secondaryColor = "secondaryColor"
        static let language = "language"
        static let totalCount = "totalCount"
        static let totalCollections = "totalCollections"
    }

    // MARK: - Persistence
    func saveCredentials() {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
        userDefaults.set(merchantId, forKey: Keys.merchantId)
        userDefaults.set(terminalId, forKey: Keys.terminalId)
        userDefaults.set(serialNumber, forKey: Keys.serialNumber)
        userDefaults.set(apiKey, forKey: Keys.apiKey)
        userDefaults.set(apiDomain, forKey: Keys.apiDomain)
        userDefaults.set(primaryColor.toHex(), forKey: Keys.primaryColor)
        userDefaults.set(secondaryColor.toHex(), forKey: Keys.secondaryColor)
        userDefaults.set(language, forKey: Keys.language)
        userDefaults.set(totalCount, forKey: Keys.totalCount)
        userDefaults.set(totalCollections, forKey: Keys.totalCollections)
    }

    func loadSavedCredentials() {
        isLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        merchantId = userDefaults.string(forKey: Keys.merchantId) ?? ""
        terminalId = userDefaults.string(forKey: Keys.terminalId) ?? ""
        serialNumber = userDefaults.string(forKey: Keys.serialNumber) ?? ""
        apiKey = userDefaults.string(forKey: Keys.apiKey) ?? ""
        apiDomain = userDefaults.string(forKey: Keys.apiDomain) ?? "https://impcoden.ftsafe.com:8443"
        language = userDefaults.string(forKey: Keys.language) ?? "English"

        if let hex = userDefaults.string(forKey: Keys.primaryColor), !hex.isEmpty {
            primaryColor = Color(hex: hex)
        }
        if let hex = userDefaults.string(forKey: Keys.secondaryColor), !hex.isEmpty {
            secondaryColor = Color(hex: hex)
        }

        totalCount = userDefaults.integer(forKey: Keys.totalCount)
        totalCollections = userDefaults.double(forKey: Keys.totalCollections)
    }

    func login(user: User) {
        currentUser = user
        isLoggedIn = true
        saveCredentials()
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
    }

    func updateStatistics(count: Int, collections: Double) {
        totalCount = count
        totalCollections = collections
        saveCredentials()
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
