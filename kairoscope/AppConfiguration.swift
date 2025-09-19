import Foundation

/// Global configuration values loaded at app launch.
struct AppConfiguration: Decodable {
    /// Feature flag controlling whether authentication gates the timeline.
    let isAuthEnabled: Bool
    /// Base URL for backend API requests (placeholder until backend spec finalizes).
    let apiBaseURL: URL

    private enum CodingKeys: String, CodingKey {
        case isAuthEnabled
        case apiBaseURL
    }

    init(isAuthEnabled: Bool, apiBaseURL: URL) {
        self.isAuthEnabled = isAuthEnabled
        self.apiBaseURL = apiBaseURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAuthEnabled = try container.decode(Bool.self, forKey: .isAuthEnabled)
        let apiBaseURLString = try container.decode(String.self, forKey: .apiBaseURL)
        guard let resolvedURL = URL(string: apiBaseURLString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .apiBaseURL,
                in: container,
                debugDescription: "apiBaseURL must be a valid URL string"
            )
        }
        apiBaseURL = resolvedURL
    }
}

extension AppConfiguration {
    enum LoadError: Error {
        case resourceMissing
        case decodeFailed(Error)
    }

    /// Loads configuration from `AppConfiguration.plist` bundled with the app.
    /// - Parameter bundle: Injection point for tests and previews.
    static func load(from bundle: Bundle = .main) throws -> AppConfiguration {
        guard let url = bundle.url(forResource: "AppConfiguration", withExtension: "plist") else {
            throw LoadError.resourceMissing
        }
        do {
            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode(AppConfiguration.self, from: data)
        } catch {
            throw LoadError.decodeFailed(error)
        }
    }

    /// Convenience helper for previews/tests needing quick overrides.
    static func mock(isAuthEnabled: Bool = false, apiBaseURL: URL = URL(string: "https://api.dev.kairoscope.app")!) -> AppConfiguration {
        AppConfiguration(isAuthEnabled: isAuthEnabled, apiBaseURL: apiBaseURL)
    }
}

extension AppConfiguration.LoadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .resourceMissing:
            return "AppConfiguration.plist missing from main bundle"
        case let .decodeFailed(error):
            return "Failed to decode AppConfiguration.plist: \(error.localizedDescription)"
        }
    }
}
