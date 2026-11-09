import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosLayout extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onOpenFile;
  final VoidCallback onCreateFolder;
  final VoidCallback onSelectFolder;
  final Map<String, List<String>> folderFiles;
  final ValueChanged<String> onDeleteFolder;
  final ValueChanged<String> onOpenDrawerFile;

  const MacosLayout({
    super.key,
    required this.onSave,
    required this.onOpenFile,
    required this.onCreateFolder,
    required this.onSelectFolder,
    required this.folderFiles,
    required this.onDeleteFolder,
    required this.onOpenDrawerFile,
  });

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
              _SectionHeader(label: 'Dossiers', onAdd: widget.onSelectFolder),
              ...widget.folderFiles.entries.map(
                (entry) => _SidebarFolderItem(
                  path: entry.key,
                  files: entry.value,
                  selected: false,
                  onDelete: () => widget.onDeleteFolder(entry.key),
                  onOpenFile: widget.onOpenDrawerFile,
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
                child: const Text('Ouvrir un fichier'),
                onPressed: () => widget.onOpenFile(),
              ),
              const SizedBox(height: 8),
              PushButton(
                controlSize: ControlSize.large,
                child: const Text('Ouvrir un dossier'),
                onPressed: () => widget.onSelectFolder(),
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
  final VoidCallback? onAdd;

  const _SectionHeader({required this.label, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
          ),
          const Spacer(),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: MacosIcon(
                CupertinoIcons.plus,
                size: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarFolderItem extends StatefulWidget {
  final String path;
  final List<String> files;
  final bool selected;
  final VoidCallback onDelete;
  final ValueChanged<String> onOpenFile;

  const _SidebarFolderItem({
    required this.path,
    required this.files,
    required this.selected,
    required this.onDelete,
    required this.onOpenFile,
  });

  @override
  State<_SidebarFolderItem> createState() => _SidebarFolderItemState();
}

class _SidebarFolderItemState extends State<_SidebarFolderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness.isDark;
    final name = widget.path.split(Platform.pathSeparator).last;

    return GestureDetector(
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
          if (value == 'delete') widget.onDelete();
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 1),
              decoration: ShapeDecoration(
                color: widget.selected
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
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: MacosIcon(
                      CupertinoIcons.chevron_right,
                      color: widget.selected ? Colors.white : theme.primaryColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  MacosIcon(
                    CupertinoIcons.folder,
                    color: widget.selected ? Colors.white : theme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: widget.selected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.files.map((filePath) {
                  final fileName = filePath.split(Platform.pathSeparator).last;
                  return GestureDetector(
                    onTap: () => widget.onOpenFile(filePath),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: ShapeDecoration(
                        color: MacosColors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          MacosIcon(
                            CupertinoIcons.doc_text,
                            color: theme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
