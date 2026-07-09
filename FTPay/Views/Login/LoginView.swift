import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header with Logo
                    VStack(spacing: 16) {
                        Spacer().frame(height: geometry.safeAreaInsets.top + 20)

                        // Logo
                        VStack(spacing: 8) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 56))
                                .foregroundColor(Color(hex: "#007AFF"))

                            Text("FT PAY")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "#1a1a2e"))

                            Text("Merchant Payment Solution")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Card Illustration
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#007AFF"), Color(hex: "#5856D6")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 200, height: 120)
                                .shadow(color: Color(hex: "#007AFF").opacity(0.3), radius: 12, x: 0, y: 6)

                            VStack {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Image(systemName: "contactless")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                HStack {
                                    Text("**** **** **** 5981")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .padding()
                            .frame(width: 200, height: 120)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemGray6))

                    // Login Form
                    VStack(spacing: 20) {
                        Spacer().frame(height: 24)

                        VStack(spacing: 16) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("User (Email)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.secondary)
                                    TextField("merchant@example.com", text: $email)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.secondary)
                                    SecureField("Enter password", text: $password)
                                        .textContentType(.password)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }

                        // Error Message
                        if showError, let error = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        // Login Button
                        Button(action: handleLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("LOGIN")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                isFormValid ? Color(hex: "#007AFF") : Color.gray
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!isFormValid || isLoading)

                        Spacer().frame(height: 16)

                        // Version
                        Text("Version v3.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    private func handleLogin() {
        guard isFormValid else { return }

        isLoading = true
        showError = false

        Task {
            do {
                let user = try await APIService.shared.login(email: email, password: password)
                await MainActor.run {
                    appState.login(user: user)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}
