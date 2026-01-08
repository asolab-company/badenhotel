import SwiftUI

let onboardingShownKey = "onboardingShown"

enum AppRoute: Equatable {
    case loading
    case onboarding
    case main

}

struct RootView: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "180F22"), Color(hex: "383164")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            currentScreen
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch route {
        case .loading:
            Loading {
                let needsOnboarding = !UserDefaults.standard.bool(
                    forKey: onboardingShownKey
                )
                route = needsOnboarding ? .onboarding : .main
            }

        case .onboarding:
            WelcomeView {
                UserDefaults.standard.set(true, forKey: onboardingShownKey)
                route = .main
            }

        case .main:
            BottomBarRootView()

        }
    }
}

#Preview {
    RootView()
}
