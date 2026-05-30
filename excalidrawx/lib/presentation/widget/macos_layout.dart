import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosLayout extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCreateFolder;
  final VoidCallback onSelectFolder;
  final List<String> listFolder;
  final ValueChanged<String> onDeleteFolder;

  const MacosLayout({super.key, required this.onSave, required this.onCreateFolder, required this.onSelectFolder, required this.listFolder, required this.onDeleteFolder});

  @override
  State<MacosLayout> createState() => _MacosLayout();
}

class _MacosLayout extends State<MacosLayout> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(10),
            children: [
              _SidebarItemWidget(
                icon: CupertinoIcons.home,
                label: 'Accueil',
                selected: pageIndex == 0,
                onTap: () => setState(() => pageIndex = 0),
              ),
              _SectionHeader(label: 'Dossiers'),
              ...widget.listFolder.map(
                (path) => _SidebarFolderItem(
                  path: path,
                  selected: false,
                  onTap: () {},
                  onDelete: () => widget.onDeleteFolder(path),
                ),
              ),
            ],
          );
        },
        bottom: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PushButton(
                controlSize: ControlSize.large,
                child: const Text('Nouveau dessin'),
                onPressed: () => widget.onSave(),
              ),
              const SizedBox(height: 8),
              PushButton(
                controlSize: ControlSize.large,
                child: const Text('Ouvrir un dossier'),
                onPressed: () => widget.onSelectFolder(),
              ),
              const SizedBox(height: 8),
              PushButton(
                controlSize: ControlSize.large,
                child: const Text('Nouveau dossier'),
                onPressed: () => widget.onCreateFolder(),
              ),
            ],
          ),
        ),
      ),
      endSidebar: Sidebar(
        startWidth: 200,
        minWidth: 200,
        maxWidth: 300,
        shownByDefault: false,
        builder: (context, _) {
          return const Center(
            child: Text('End Sidebar'),
          );
        },
      ),
      child: _buildPage(pageIndex),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Center();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SidebarItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: ShapeDecoration(
          color: selected
              ? (isDark
                  ? MacosColor.fromRGBO(22, 105, 229, 0.749)
                  : MacosColor.fromRGBO(9, 129, 255, 0.749))
              : MacosColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            MacosIcon(
              icon,
              color: selected ? Colors.white : theme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _SidebarFolderItem extends StatelessWidget {
  final String path;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SidebarFolderItem({
    required this.path,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness.isDark;
    final name = path.split(Platform.pathSeparator).last;

    return GestureDetector(
      onTap: onTap,
      onSecondaryTapUp: (details) {
        showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx + 1,
            details.globalPosition.dy + 1,
          ),
          items: [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(CupertinoIcons.delete, size: 16),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ).then((value) {
          if (value == 'delete') onDelete();
        });
      },
      child: Container(
        width: double.infinity,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: ShapeDecoration(
          color: selected
              ? (isDark
                  ? MacosColor.fromRGBO(22, 105, 229, 0.749)
                  : MacosColor.fromRGBO(9, 129, 255, 0.749))
              : MacosColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            MacosIcon(
              CupertinoIcons.folder,
              color: selected ? Colors.white : theme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}