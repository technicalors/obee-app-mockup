import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionCredentialsProvider = Provider<SessionCredentials>(
  (ref) => SessionCredentials(),
);

/// Live request credentials shared by authentication and the HTTP transport.
/// Secure storage is read only by the authentication controller during restore.
final class SessionCredentials {
  String? _token;
  bool _isAvailable = false;

  String? get token => _token;
  bool get isAvailable => _isAvailable;

  void beginRestore() {
    _isAvailable = false;
  }

  void restore(String? token) {
    _token = token;
    _isAvailable = true;
  }
}
