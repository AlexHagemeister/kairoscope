import Foundation

/// Represents the current authentication state for the signed-in user (if any).
struct AuthSession {
    let isAuthenticated: Bool
    let userID: String?
}

/// Abstraction for authentication providers (Apple, Google, mock implementations).
protocol AuthService {
    func currentSession() -> AuthSession
}

/// Stub implementation used during early milestones before real auth integration exists.
struct StubAuthService: AuthService {
    private let session: AuthSession

    init(isAuthenticated: Bool, userID: String? = nil) {
        session = AuthSession(isAuthenticated: isAuthenticated, userID: userID)
    }

    func currentSession() -> AuthSession {
        session
    }
}
