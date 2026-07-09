import SwiftUI

struct BindAPIKeyView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var merchantId: String = ""
    @State private var apiKey: String = ""
    @State private var isLoading: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundColor(appState.primaryColor)

                        Text("API Key Binding")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Complete the interface configuration to enable payment capabilities")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    // Form
                    VStack(spacing: 16) {
                        // Merchant ID
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Merchant MID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(.secondary)
                                TextField("Enter Merchant ID", text: $merchantId)
                                    .autocapitalization(.allCharacters)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        // API Key
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("API Key")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: pasteFromClipboard) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.clipboard")
                                        Text("Paste")
                                    }
                                    .font(.caption)
                                    .foregroundColor(appState.primaryColor)
                                }
                            }
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(.secondary)
                                if apiKey.isEmpty {
                                    TextField("Enter API Key", text: $apiKey)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("API Key", text: $apiKey)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        // Security Notice
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Your API Key is encrypted and stored securely on this device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    // Error
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
                    }

                    // Bind Button
                    Button(action: handleBind) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "link")
                                Text("Confirm Binding")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? appState.primaryColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)

                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to get your API Key:")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            bulletPoint("1. Log in to NMI Partner Platform")
                            bulletPoint("2. Navigate to Settings > API Credentials")
                            bulletPoint("3. Copy your API Key")
                            bulletPoint("4. Enter your Merchant MID and API Key above")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
        }
        .navigationTitle("Bind API Key")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Binding Successful", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your API Key has been bound successfully.")
        }
    }

    private var isFormValid: Bool {
        !merchantId.isEmpty && !apiKey.isEmpty && apiKey.count >= 8
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func pasteFromClipboard() {
        if let clipboardString = UIPasteboard.general.string {
            apiKey = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func handleBind() {
        guard isFormValid else { return }

        isLoading = true
        showError = false

        Task {
            do {
                let request = APIBindingRequest(
                    merchantId: merchantId,
                    apiKey: apiKey,
                    domain: appState.apiDomain
                )
                let response = try await APIService.shared.bindAPIKey(request: request)

                await MainActor.run {
                    isLoading = false
                    if response.success {
                        if let info = response.merchantInfo {
                            appState.merchantId = info.merchantId
                            appState.terminalId = info.terminalId
                            appState.serialNumber = info.serialNumber
                        }
                        appState.apiKey = apiKey
                        appState.saveCredentials()
                        showSuccess = true
                    } else {
                        errorMessage = response.message
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
