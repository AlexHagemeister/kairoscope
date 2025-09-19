import Foundation

/// Central dependency container injected into SwiftUI environment.
struct AppEnvironment {
    let configuration: AppConfiguration
    let authService: any AuthService
    var timelineFactory: TimelineFactory

    /// Convenience factory for standard runtime environment.
    static func live(configuration: AppConfiguration) -> AppEnvironment {
        AppEnvironment(
            configuration: configuration,
            authService: StubAuthService(isAuthenticated: false),
            timelineFactory: .default
        )
    }

    /// Convenience factory for previews and tests with override flags.
    static func preview(isAuthEnabled: Bool = false) -> AppEnvironment {
        let configuration = AppConfiguration.mock(isAuthEnabled: isAuthEnabled)
        return .live(configuration: configuration)
    }
}

/// Bundles constructors for timeline-related engines.
struct TimelineFactory {
    var makeTimeScaleEngine: () -> TimeScaleEngine
    var makeTimelineClock: () -> TimelineClock

    static let `default` = TimelineFactory(
        makeTimeScaleEngine: { TimeScaleEngine() },
        makeTimelineClock: { TimelineClock() }
    )
}
