import SwiftUI

struct PasswordVerifyView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isVerified: Bool = false

    let onVerified: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Merchant Info Header
                    VStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(appState.primaryColor)

                        Text("Verification Required")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Enter your password to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Merchant Info
                    if let user = appState.currentUser {
                        VStack(spacing: 4) {
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            if !appState.merchantId.isEmpty {
                                Text("MID: \(appState.merchantId)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Password Dots
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index < password.count ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.vertical, 8)

                    // Error Message
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    // Numeric Keypad
                    PasswordKeypadView(
                        password: $password,
                        maxLength: 6,
                        onConfirm: handleVerify,
                        onCancel: { dismiss() }
                    )
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: password) { _, newValue in
            if newValue.count == 6 {
                handleVerify()
            }
        }
    }

    private func handleVerify() {
        // Simple verification - in production, this would validate against a server
        // For demo purposes, any 6-digit password is accepted
        guard password.count == 6 else { return }

        if isValidPassword(password) {
            isVerified = true
            onVerified()
            dismiss()
        } else {
            errorMessage = "Incorrect password"
            showError = true
            password = ""
        }
    }

    private func isValidPassword(_ pwd: String) -> Bool {
        // In production, verify against the server
        // For demo: accept any 6-digit number
        return pwd.count == 6 && pwd.allSatisfy { $0.isNumber }
    }
}
