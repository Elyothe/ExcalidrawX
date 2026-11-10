import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

  const GlobalAppBar({
    super.key,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.surface,
      foregroundColor: AppTheme.text,
      elevation: 0,
      leadingWidth: defaultTargetPlatform == TargetPlatform.macOS
          ? 128
          : kToolbarHeight,
      leading: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          tooltip: isSidebarOpen ? 'Fermer le panneau' : 'Ouvrir le panneau',
          icon: const Icon(Icons.view_sidebar),
          onPressed: onToggleSidebar,
        ),
      ),
    );
  }
}
