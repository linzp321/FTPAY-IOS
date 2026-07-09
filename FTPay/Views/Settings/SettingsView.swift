import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var isSaving: Bool = false
    @State private var showSavedAlert: Bool = false

    @State private var tempPrimaryColor: Color = Color(hex: "#007AFF")
    @State private var tempSecondaryColor: Color = Color(hex: "#5856D6")
    @State private var tempDomain: String = "https://impcoden.ftsafe.com:8443"
    @State private var tempLanguage: String = "English"

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(appState.primaryColor)
                    }
                    Spacer()
                    Text("Customer Settings")
                        .font(.headline)
                    Spacer()
                    Button(action: saveSettings) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                                .foregroundColor(appState.primaryColor)
                        }
                    }
                    .disabled(isSaving)
                }
                .padding()
                .background(Color(.systemBackground))

                ScrollView {
                    VStack(spacing: 20) {
                        // Primary Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color Primary")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                ForEach(presetColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(tempPrimaryColor.toHex() == color.toHex() ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            tempPrimaryColor = color
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Secondary Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color Secondary")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                ForEach(secondaryColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(tempSecondaryColor.toHex() == color.toHex() ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            tempSecondaryColor = color
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Domain
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Change Domain")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextField("https://example.com", text: $tempDomain)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Language
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Language")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Language", selection: $tempLanguage) {
                                ForEach(languages, id: \.self) { lang in
                                    Text(lang).tag(lang)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // API Key Binding
                        NavigationLink(destination: BindAPIKeyView()) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(appState.primaryColor)
                                Text("Bind API Key")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }

                        // App Info
                        VStack(spacing: 8) {
                            HStack {
                                Text("App Version")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("v3.0.0")
                                    .foregroundColor(.primary)
                            }
                            Divider()
                            HStack {
                                Text("Build")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("2026.07.09")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            tempPrimaryColor = appState.primaryColor
            tempSecondaryColor = appState.secondaryColor
            tempDomain = appState.apiDomain
            tempLanguage = appState.language
        }
        .alert("Settings Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private let presetColors: [Color] = [
        Color(hex: "#007AFF"),
        Color(hex: "#5856D6"),
        Color(hex: "#FF2D55"),
        Color(hex: "#FF9500"),
        Color(hex: "#34C759"),
        Color(hex: "#00C7BE"),
    ]

    private let secondaryColors: [Color] = [
        Color(hex: "#5856D6"),
        Color(hex: "#AF52DE"),
        Color(hex: "#FF375F"),
        Color(hex: "#FF9F0A"),
        Color(hex: "#30D158"),
        Color(hex: "#64D2FF"),
    ]

    private let languages = ["English", "中文", "日本語", "한국어", "Español"]

    private func saveSettings() {
        isSaving = true
        Task {
            do {
                try await APIService.shared.updateSettings(
                    primaryColor: tempPrimaryColor.toHex(),
                    secondaryColor: tempSecondaryColor.toHex(),
                    domain: tempDomain,
                    language: tempLanguage
                )
                await MainActor.run {
                    appState.primaryColor = tempPrimaryColor
                    appState.secondaryColor = tempSecondaryColor
                    appState.apiDomain = tempDomain
                    appState.language = tempLanguage
                    appState.saveCredentials()
                    isSaving = false
                    showSavedAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}
