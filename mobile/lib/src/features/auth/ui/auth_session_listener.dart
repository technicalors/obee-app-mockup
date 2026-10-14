import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';

class AuthSessionListener extends ConsumerStatefulWidget {
  const AuthSessionListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthSessionListener> createState() =>
      _AuthSessionListenerState();
}

class _AuthSessionListenerState extends ConsumerState<AuthSessionListener> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _refreshSession);
  }

  void _refreshSession() {
    unawaited(ref.read(authControllerProvider.notifier).refreshCurrentUser());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (next.isAuthenticated &&
          message != null &&
          message != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    return widget.child;
  }
}
