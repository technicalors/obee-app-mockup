import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;
  var _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactWidth = constraints.maxWidth < 360;
                final horizontalPadding = compactWidth ? 16.0 : 24.0;
                final topPadding = constraints.maxHeight < 700 ? 12.0 : 16.0;

                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          math.max(32, viewInsets.bottom + 24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _LoginHeader(),
                            const SizedBox(height: 28),
                            Card(
                              elevation: 4,
                              shadowColor: colorScheme.shadow.withValues(
                                alpha: 0.06,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: AutofillGroup(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextFormField(
                                          key: const ValueKey('login_email'),
                                          controller: _emailController,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.username,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Mã nhân viên',
                                            hintText: 'Nhập mã nhân viên',
                                            prefixIcon: Icon(
                                              Icons.badge_outlined,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Vui lòng nhập mã nhân viên.';
                                            }

                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          key: const ValueKey('login_password'),
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Mật khẩu',
                                            hintText: 'Nhập mật khẩu',
                                            prefixIcon: const Icon(
                                              Icons.lock_outline,
                                            ),
                                            suffixIcon: IconButton(
                                              tooltip: _obscurePassword
                                                  ? 'Hiện mật khẩu'
                                                  : 'Ẩn mật khẩu',
                                              onPressed: () {
                                                setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                );
                                              },
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.length < 6) {
                                              return 'Mật khẩu phải có ít nhất 6 ký tự.';
                                            }

                                            return null;
                                          },
                                          onFieldSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                key: const ValueKey(
                                                  'login_remember_me',
                                                ),
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(
                                                    () => _rememberMe =
                                                        value ?? false,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Ghi nhớ đăng nhập',
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (auth.errorMessage != null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            _translateAuthMessage(
                                              auth.errorMessage!,
                                            ),
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 20),
                                        FilledButton(
                                          key: const ValueKey(
                                            'login_submit_button',
                                          ),
                                          onPressed: auth.isLoading
                                              ? null
                                              : _submit,
                                          child: auth.isLoading
                                              ? SizedBox.square(
                                                  dimension: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: colorScheme
                                                            .onPrimary,
                                                      ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text('Đăng nhập'),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _SecurityNote(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  String _translateAuthMessage(String message) {
    return switch (message) {
      'authConnectError' => 'Không thể kết nối máy chủ.',
      _ => message,
    };
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final showDecorations = MediaQuery.sizeOf(context).width >= 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (showDecorations) const _HeaderDecorations(),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Chào mừng trở lại',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tổ chức công việc và theo sát mọi đầu việc của bạn.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _HeaderDecorations extends StatelessWidget {
  const _HeaderDecorations();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 108,
      height: 92,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: _DecorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hôm nay',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _DecorLine(width: 34),
                  const SizedBox(height: 4),
                  const _DecorLine(width: 24),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 0,
            child: _DecorCard(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: colorScheme.primary.withValues(alpha: 0.9),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _DecorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '72%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 52,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.72,
                        minHeight: 5,
                        backgroundColor: colorScheme.outlineVariant,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCard extends StatelessWidget {
  const _DecorCard({
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DecorLine extends StatelessWidget {
  const _DecorLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'An toàn. Riêng tư. Hiệu quả. Dữ liệu của bạn được bảo vệ với chuẩn bảo mật doanh nghiệp.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(painter: _LoginBackgroundPainter(colorScheme));
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final topBlob = Paint()
      ..color = colorScheme.primaryContainer.withValues(alpha: 0.35);
    final bottomBlob = Paint()
      ..color = colorScheme.primaryContainer.withValues(alpha: 0.25);

    canvas.drawCircle(Offset(size.width * 0.12, -24), 120, topBlob);
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.08),
      88,
      topBlob,
    );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.92),
      110,
      bottomBlob,
    );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.88),
      96,
      bottomBlob,
    );

    _paintHoneycomb(canvas, const Offset(18, 18), 5, 3);
  }

  void _paintHoneycomb(Canvas canvas, Offset origin, int columns, int rows) {
    const radius = 10.0;
    final paint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final xOffset = col * radius * 1.75 + (row.isOdd ? radius * 0.875 : 0);
        final center = origin + Offset(xOffset, row * radius * 1.5);
        _paintHexagon(canvas, center, radius, paint);
      }
    }
  }

  void _paintHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
