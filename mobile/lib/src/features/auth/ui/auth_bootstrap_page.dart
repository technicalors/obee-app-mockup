import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';

class AuthBootstrapPage extends ConsumerWidget {
  const AuthBootstrapPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: auth.restoreFailed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(auth.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('auth_restore_retry'),
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .retryRestore(),
                      child: const Text('Thử lại'),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                      child: const Text('Đăng xuất trên thiết bị'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
