import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/widgets/app_top_bar.dart';

export 'package:obee_mobile/src/core/widgets/app_top_bar.dart';

class StandalonePageHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const StandalonePageHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.onBackPressed,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    return AppTopBar(
      title: title,
      leading: leading,
      showBackButton: leading == null,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }
}

class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconSize = 24,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize, color: color ?? colorScheme.onSurface),
      onPressed: onPressed,
    );
  }
}
