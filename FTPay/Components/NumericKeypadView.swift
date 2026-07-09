import SwiftUI

// MARK: - Numeric Keypad View
struct NumericKeypadView: View {
    @Binding var value: String
    let maxLength: Int
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?

    private let keys: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.digit("00"), .digit("0"), .backspace]
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Display
            HStack {
                Text("$")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                Text(value.isEmpty ? "0.00" : formatDisplay(value))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(value.isEmpty ? .gray : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Keypad Grid
            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(keys[row]) { key in
                            KeypadButton(key: key) {
                                handleKey(key)
                            }
                        }
                    }
                }
            }

            // Confirm Button
            Button(action: onConfirm) {
                Text("OK")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        value.isEmpty ? Color.gray : Color.green
                    )
                    .cornerRadius(12)
            }
            .disabled(value.isEmpty)
        }
        .padding()
    }

    private func handleKey(_ key: KeypadKey) {
        switch key {
        case .digit(let d):
            if value.count < maxLength {
                if value.contains(".") {
                    let parts = value.split(separator: ".")
                    if parts.count == 1 || parts[1].count < 2 {
                        value += d
                    }
                } else {
                    value += d
                }
            }
        case .backspace:
            if !value.isEmpty {
                value.removeLast()
            }
        }
    }

    private func formatDisplay(_ text: String) -> String {
        if text.isEmpty { return "0.00" }
        if !text.contains(".") {
            return text + ".00"
        }
        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count == 1 { return text + "00" }
        if parts[1].count == 1 { return text + "0" }
        return text
    }
}

// MARK: - Keypad Key Enum
enum KeypadKey: Identifiable, Equatable {
    case digit(String)
    case backspace

    var id: String {
        switch self {
        case .digit(let s): return s
        case .backspace: return "back"
        }
    }

    var displayText: String {
        switch self {
        case .digit(let s): return s
        case .backspace: return "X"
        }
    }
}

// MARK: - Keypad Button
struct KeypadButton: View {
    let key: KeypadKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if key == .backspace {
                    Image(systemName: "delete.left")
                        .font(.title2)
                } else {
                    Text(key.displayText)
                        .font(.title)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color(.systemGray5))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Password Keypad (for verification)
struct PasswordKeypadView: View {
    @Binding var password: String
    let maxLength: Int
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?

    private let keys: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.cancel, .digit("0"), .confirm]
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Password Dots Display
            HStack(spacing: 12) {
                ForEach(0..<maxLength, id: \.self) { index in
                    Circle()
                        .fill(index < password.count ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.top, 8)

            // Keypad Grid
            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(keys[row]) { key in
                            PwdKeypadButton(key: key) {
                                handleKey(key)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func handleKey(_ key: KeypadKey) {
        switch key {
        case .digit(let d):
            if password.count < maxLength {
                password += d
            }
        case .backspace:
            if !password.isEmpty {
                password.removeLast()
            }
        }
    }
}

struct PwdKeypadButton: View {
    let key: KeypadKey
    let action: () -> Void

    private var isConfirm: Bool { key == .confirm || key.displayText == "OK" }
    private var isCancel: Bool { key == .cancel || key.displayText == "X" }

    var body: some View {
        Button(action: action) {
            Group {
                if key == .backspace {
                    Image(systemName: "delete.left")
                        .font(.title2)
                } else {
                    Text(key == .confirm ? "OK" : key.displayText)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                isConfirm ? Color.green :
                isCancel ? Color.red.opacity(0.7) :
                Color(.systemGray5)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
