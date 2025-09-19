import SwiftUI

struct RootView: View {
    @Environment(\.appConfiguration) private var configuration
    @Environment(\.appEnvironment) private var environment

    private var session: AuthSession {
        environment.authService.currentSession()
    }

    var body: some View {
        Group {
            if configuration.isAuthEnabled && session.isAuthenticated == false {
                AuthGateView()
            } else {
                TimelineShellView()
            }
        }
    }
}

#Preview("Auth Enabled - Requires Sign In") {
    RootView()
        .environment(\.appConfiguration, .mock(isAuthEnabled: true))
        .environment(\.appEnvironment, .preview(isAuthEnabled: true))
}

#Preview("Auth Disabled - Direct Timeline") {
    RootView()
        .environment(\.appConfiguration, .mock(isAuthEnabled: false))
        .environment(\.appEnvironment, .preview(isAuthEnabled: false))
}

#Preview("Auth Enabled - Already Signed In") {
    let configuration = AppConfiguration.mock(isAuthEnabled: true)
    let environment = AppEnvironment(
        configuration: configuration,
        authService: StubAuthService(isAuthenticated: true, userID: "demo"),
        timelineFactory: .default
    )

    return RootView()
        .environment(\.appConfiguration, configuration)
        .environment(\.appEnvironment, environment)
}
