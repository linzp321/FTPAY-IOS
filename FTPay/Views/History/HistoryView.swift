import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("加载中…")
                        .progressViewStyle(.circular)
                } else if appState.transactions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无交易记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("完成第一笔交易后将在这里显示")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(appState.transactions) { tx in
                        TransactionRow(transaction: tx)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadHistory()
                    }
                }
            }
            .navigationTitle("交易记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await loadHistory() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadHistory()
            }
        }
    }
    
    private func loadHistory() async {
        isLoading = true
        defer { isLoading = false }
        // 实际项目里这里调用 APIService.fetchHistory
        try? await Task.sleep(nanoseconds: 300_000_000)
    }
}
