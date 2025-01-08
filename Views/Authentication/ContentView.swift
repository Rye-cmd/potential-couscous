import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Group {
                if !appState.isAuthenticated {
                    LoginView()
                } else if appState.isOnboarding {
                    OnboardingView {
                        Task {
                            await appState.completeOnboarding()
                        }
                    }
                } else if let user = appState.currentUser {
                    TalentDashboardView(user: user)
                } else {
                    ProgressView("Loading user data...")
                }
            }
            .animation(.default, value: appState.isAuthenticated)
            .animation(.default, value: appState.isOnboarding)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
