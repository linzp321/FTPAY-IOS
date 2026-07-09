import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: HistoryFilter = .week
    @State private var transactions: [Transaction] = []
    @State private var isLoading: Bool = false
    @State private var selectedDate: Date = Date()

    // Date range for the filter
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter()
    }()

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    NavigationLink(destination: HomeView().navigationBarBackButtonHidden(true)) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(appState.primaryColor)
                    }
                    Spacer()
                    Text("History")
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding()
                .background(Color(.systemBackground))

                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Tabs
                        filterTabs

                        // Date Selector
                        dateSelector

                        // Transactions List
                        transactionsList
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadTransactions()
        }
        .onChange(of: selectedFilter) { _, _ in
            loadTransactions()
        }
    }

    // MARK: - Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter.displayName)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedFilter == filter ? appState.primaryColor : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }

    // MARK: - Date Selector
    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(getDateRange(), id: \.self) { date in
                        DateChip(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            onTap: { selectedDate = date }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Transactions List
    private var transactionsList: some View {
        VStack(spacing: 12) {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            } else if transactions.isEmpty {
                emptyState
            } else {
                // Summary Card
                summaryCard

                // Transaction Cards
                ForEach(groupedTransactions.keys.sorted().reversed(), id: \.self) { dateKey in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dateKey)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            ForEach(groupedTransactions[dateKey] ?? []) { transaction in
                                TransactionRow(transaction: transaction)
                                if transaction.id != (groupedTransactions[dateKey]?.last?.id) {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No transactions found")
                .font(.headline)
            Text("Transactions will appear here after your first payment")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(48)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Transactions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(transactions.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(appState.primaryColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Total Amount")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "$%.2f", transactions.reduce(0) { $0 + $1.amount }))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Helpers
    private var groupedTransactions: [String: [Transaction]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return Dictionary(grouping: transactions) { transaction in
            formatter.string(from: transaction.timestamp)
        }
    }

    private func getDateRange() -> [Date] {
        let today = Date()
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }
    }

    private func loadTransactions() {
        isLoading = true
        Task {
            do {
                let fetched = try await APIService.shared.fetchTransactions(filter: selectedFilter)
                await MainActor.run {
                    transactions = fetched
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    transactions = Transaction.sampleTransactions
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Date Chip
struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter()
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter()
    }()

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(formatter.string(from: date).uppercased())
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(dayFormatter.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 48, height: 60)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(12)
        }
    }
}
