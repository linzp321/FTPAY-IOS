import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            appState.loadSavedCredentials()
        }
    }
}
