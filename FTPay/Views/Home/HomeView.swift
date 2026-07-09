import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showDrawer: Bool = false
    @State private var navigateToPurchase: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Merchant Info Card
                        MerchantInfoCard(
                            merchantId: appState.merchantId,
                            terminalId: appState.terminalId,
                            serialNumber: appState.serialNumber,
                            primaryColor: appState.primaryColor
                        )

                        // Statistics Card
                        StatisticsCard(
                            totalCount: appState.totalCount,
                            totalCollections: appState.totalCollections,
                            primaryColor: appState.primaryColor
                        )

                        // Recent Transactions
                        if !appState.recentTransactions.isEmpty {
                            RecentTransactionsCard(
                                transactions: appState.recentTransactions,
                                primaryColor: appState.primaryColor
                            )
                        }

                        Spacer().frame(height: 80)
                    }
                    .padding()
                }

                // Floating NFC Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            navigateToPurchase = true
                        }) {
                            Image(systemName: "wave.3.right")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(appState.primaryColor)
                                .clipShape(Circle())
                                .shadow(color: appState.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }

                // NavigationLink for Purchase
                NavigationLink(
                    destination: PurchaseView(),
                    isActive: $navigateToPurchase
                ) { EmptyView() }
            }
            .navigationTitle("FTPAY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showDrawer = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("FTPAY")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showDrawer) {
                DrawerMenuView(isPresented: $showDrawer)
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        Task {
            do {
                let transactions = try await APIService.shared.fetchTransactions(filter: .week)
                await MainActor.run {
                    appState.recentTransactions = Array(transactions.prefix(5))
                }
            } catch {
                // Silently fail, use sample data
                await MainActor.run {
                    appState.recentTransactions = Array(Transaction.sampleTransactions.prefix(5))
                }
            }
        }
    }
}

// MARK: - Recent Transactions Card
struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    let primaryColor: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(primaryColor)
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: HistoryView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(primaryColor)
                }
            }

            Divider()

            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
                if transaction.id != transactions.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Drawer Menu
struct DrawerMenuView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var showPasswordVerify: Bool = false
    @State private var pendingDestination: Destination?

    enum Destination: Identifiable {
        case settings
        case bindAPIKey
        case history
        case purchase

        var id: String {
            switch self {
            case .settings: return "settings"
            case .bindAPIKey: return "bindAPIKey"
            case .history: return "history"
            case .purchase: return "purchase"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 48))
                        .foregroundColor(appState.primaryColor)

                    Text("FTPAY")
                        .font(.title)
                        .fontWeight(.bold)

                    if let user = appState.currentUser {
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [appState.primaryColor.opacity(0.1), Color(.systemGray6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Menu Items
                VStack(spacing: 4) {
                    DrawerMenuItem(icon: "clock.arrow.circlepath", title: "History") {
                        pendingDestination = .history
                        isPresented = false
                    }
                    Divider()

                    DrawerMenuItem(icon: "wave.3.right", title: "Purchase") {
                        pendingDestination = .purchase
                        isPresented = false
                    }
                    Divider()

                    DrawerMenuItem(icon: "gearshape", title: "Settings") {
                        showPasswordVerify = true
                    }
                    Divider()

                    DrawerMenuItem(icon: "key", title: "Bind API Key") {
                        pendingDestination = .bindAPIKey
                        isPresented = false
                    }
                    Divider()

                    DrawerMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Logout", isDestructive: true) {
                        appState.logout()
                        isPresented = false
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Version
                Text("FTPay v3.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 24)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPasswordVerify) {
            PasswordVerifyView(onVerified: {
                showPasswordVerify = false
                pendingDestination = .settings
                isPresented = false
            })
        }
        .onChange(of: pendingDestination) { newValue in
            if let dest = newValue {
                switch dest {
                case .settings:
                    // Navigate to settings
                    break
                case .bindAPIKey:
                    // Navigate to bind API key
                    break
                case .history:
                    // Navigation handled by NavigationLink
                    break
                case .purchase:
                    // Navigation handled by NavigationLink
                    break
                }
            }
        }
    }
}
