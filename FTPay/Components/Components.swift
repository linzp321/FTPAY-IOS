import SwiftUI

// MARK: - Merchant Info Card
struct MerchantInfoCard: View {
    let merchantId: String
    let terminalId: String
    let serialNumber: String
    let primaryColor: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(primaryColor)
                Text("Merchant Info")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            Divider()

            InfoRow(label: "Merchant ID", value: merchantId.isEmpty ? "--" : merchantId)
            InfoRow(label: "Terminal ID", value: terminalId.isEmpty ? "--" : terminalId)
            InfoRow(label: "Sn", value: serialNumber.isEmpty ? "--" : serialNumber)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Statistics Card
struct StatisticsCard: View {
    let totalCount: Int
    let totalCollections: Double
    let primaryColor: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(primaryColor)
                Text("Statistics")
                    .font(.headline)
                Spacer()
            }

            Divider()

            HStack(spacing: 20) {
                StatItem(title: "Total Count", value: "\(totalCount)", color: .blue)
                Spacer()
                StatItem(title: "Total Collections", value: String(format: "$%.2f", totalCollections), color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(transaction.cardNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(transaction.cardLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(transaction.shortDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.status == .approved ? .green : .red)
                StatusBadge(status: transaction.status)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: Transaction.TransactionStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(status == .approved ? Color.green : Color.red)
            .cornerRadius(4)
    }
}

// MARK: - Drawer Menu Item
struct DrawerMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(isDestructive ? .red : .primary)
                Text(title)
                    .foregroundColor(isDestructive ? .red : .primary)
                Spacer()
            }
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(32)
            .background(Color(.systemGray))
            .cornerRadius(16)
        }
    }
}

// MARK: - Success Overlay
struct SuccessOverlay: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)

                Text(message)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding(32)
        }
    }
}

// MARK: - Color Picker Row
struct ColorPickerRow: View {
    let title: String
    @Binding var selectedColor: Color

    private let presetColors: [Color] = [
        Color(hex: "#007AFF"),  // Blue
        Color(hex: "#5856D6"), // Purple
        Color(hex: "#FF2D55"),  // Red
        Color(hex: "#FF9500"),  // Orange
        Color(hex: "#34C759"),  // Green
        Color(hex: "#00C7BE"),  // Teal
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor.toHex() == color.toHex() ? 3 : 0)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
        }
    }
}

// MARK: - Domain Input Row
struct DomainInputRow: View {
    let title: String
    @Binding var domain: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("https://example.com", text: $domain)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

// MARK: - Language Picker Row
struct LanguagePickerRow: View {
    let title: String
    @Binding var language: String

    private let languages = ["English", "中文", "日本語", "한국어", "Español"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Picker(title, selection: $language) {
                ForEach(languages, id: \.self) { lang in
                    Text(lang).tag(lang)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
