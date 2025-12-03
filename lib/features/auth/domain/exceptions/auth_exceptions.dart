/// Base exception for authentication-related errors
abstract class AuthException implements Exception {
  final String message;
  final String? userFriendlyMessage;

  AuthException(this.message, {this.userFriendlyMessage});

  @override
  String toString() => message;
}

/// Exception for invalid email/password combinations
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException(String message)
      : super(message, userFriendlyMessage: 'The email or password is incorrect');
}

/// Exception when user email is not found in the system
class UserNotFoundException extends AuthException {
  UserNotFoundException(String message)
      : super(message, userFriendlyMessage: 'This email is not registered');
}

/// Exception for network-related errors
class NetworkException extends AuthException {
  NetworkException(String message)
      : super(message, userFriendlyMessage: 'Network error. Please check your connection');
}

/// General login exception
class LoginException extends AuthException {
  LoginException(String message)
      : super(message, userFriendlyMessage: 'Login failed. Please try again');
}