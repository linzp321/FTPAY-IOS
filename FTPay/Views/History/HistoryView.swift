import SwiftUI

struct HistoryView: View {
 @EnvironmentObject var appState: AppState
 @State private var selectedFilter: HistoryFilter = .week
 @State private var transactions: [Transaction] = []
 @State private var isLoading: Bool = false
 @State private var selectedDate: Date = Date()

 private let calendar = Calendar.current
 private let dateFormatter: DateFormatter = {
 let formatter = DateFormatter()
 formatter.dateFormat = "MMM d"
 return formatter
 }()

 var body: some View {
 ZStack {
 Color(.systemGray6)
 .ignoresSafeArea()

 VStack(spacing: 0) {
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
 filterTabs
 dateSelector
 transactionsList
 }
 .padding()
 }
 }
 }
 .navigationBarHidden(true)
 .onAppear { loadTransactions() }
 .onChange(of: selectedFilter) { _, _ in loadTransactions() }
 }

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
 summaryCard
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
 transactions = Transaction.sampleTransa
...(truncated)...
