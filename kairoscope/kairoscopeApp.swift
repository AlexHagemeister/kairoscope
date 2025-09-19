import SwiftUI
import OSLog

@main
struct KairoscopeApp: App {
    private let configuration: AppConfiguration
    private let environment: AppEnvironment

    init() {
        let logger = Logger(subsystem: "app.kairoscope", category: "configuration")
        do {
            let loadedConfig = try AppConfiguration.load()
            configuration = loadedConfig
            logger.debug("Loaded AppConfiguration: authEnabled=\(loadedConfig.isAuthEnabled, privacy: .public)")
        } catch {
            logger.error("Failed to load AppConfiguration: \(error.localizedDescription, privacy: .public)")
            configuration = .mock()
        }
        environment = .live(configuration: configuration)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appConfiguration, configuration)
                .environment(\.appEnvironment, environment)
        }
    }
}

private struct AppConfigurationKey: EnvironmentKey {
    static let defaultValue: AppConfiguration = .mock()
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .preview()
}

extension EnvironmentValues {
    var appConfiguration: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
    }

    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
