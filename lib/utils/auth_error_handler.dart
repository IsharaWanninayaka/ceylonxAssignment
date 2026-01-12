class AuthErrorHandler {
  static String handleAuthError(dynamic error, {bool isLogin = false}) {
    String errorString = error.toString().toLowerCase();

    // Common errors
    if (errorString.contains('network-request-failed') ||
        errorString.contains('network_error')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email address format.';
    }

    // Login specific errors
    if (isLogin) {
      if (errorString.contains('user-not-found')) {
        return 'No user found with this email address.';
      } else if (errorString.contains('wrong-password')) {
        return 'Incorrect password. Please try again.';
      } else if (errorString.contains('user-disabled')) {
        return 'This account has been disabled.';
      } else if (errorString.contains('too-many-requests')) {
        return 'Too many unsuccessful login attempts. Please try again later.';
      } else if (errorString.contains('operation-not-allowed')) {
        return 'Email/password sign-in is not enabled.';
      } else {
        return 'Login failed. Please check your credentials and try again.';
      }
    }
    // Register specific errors
    else {
      if (errorString.contains('email-already-in-use') ||
          errorString.contains('already-in-use')) {
        return 'An account already exists with this email address.';
      } else if (errorString.contains('weak-password')) {
        return 'Password is too weak. Please use a stronger password.';
      } else if (errorString.contains('operation-not-allowed')) {
        return 'Email/password sign-up is not enabled.';
      } else {
        return 'Registration failed. Please try again.';
      }
    }
  }
}
