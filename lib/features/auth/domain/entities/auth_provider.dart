/// How the external authentication flow is initiated.
enum AuthProvider {
  /// The backend's web login page (handles email/password there).
  web,

  /// The backend's Google OAuth authorization URL.
  google,
}
