import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'global_app_bar.dart';

class Layout extends StatefulWidget {
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onOpenFile;
  final VoidCallback onCreateFolder;
  final VoidCallback onSelectFolder;
  final Map<String, List<String>> folderFiles;
  final ValueChanged<String> onDeleteFolder;
  final ValueChanged<String> onOpenDrawerFile;

  const Layout({
    super.key,
    required this.child,
    required this.onSave,
    required this.onOpenFile,
    required this.onCreateFolder,
    required this.onSelectFolder,
    required this.folderFiles,
    required this.onDeleteFolder,
    required this.onOpenDrawerFile,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int pageIndex = 0;
  bool _isSidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      child: Scaffold(
        appBar: GlobalAppBar(
          isSidebarOpen: _isSidebarOpen,
          onToggleSidebar: () =>
              setState(() => _isSidebarOpen = !_isSidebarOpen),
        ),
        body: Row(
          children: [
            Container(
              width: _isSidebarOpen ? 220 : 0,
              color: AppTheme.surface,
              child: _isSidebarOpen
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(10),
                            children: [
                              _SidebarItemWidget(
                                icon: CupertinoIcons.home,
                                label: 'Accueil',
                                selected: pageIndex == 0,
                                onTap: () => setState(() => pageIndex = 0),
                              ),
                              _SectionHeader(
                                label: 'Dossiers',
                                onAdd: widget.onSelectFolder,
                              ),
                              ...widget.folderFiles.entries.map(
                                (entry) => _SidebarFolderItem(
                                  path: entry.key,
                                  files: entry.value,
                                  selected: false,
                                  onDelete: () =>
                                      widget.onDeleteFolder(entry.key),
                                  onOpenFile: widget.onOpenDrawerFile,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: _DarkButton(
                                  label: 'Ouvrir un fichier',
                                  onPressed: widget.onOpenFile,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: _DarkButton(
                                  label: 'Ouvrir un dossier',
                                  onPressed: widget.onSelectFolder,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DarkButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.button,
        foregroundColor: AppTheme.text,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: ShapeDecoration(
          color: selected ? AppTheme.selected : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.text : AppTheme.accent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.text : AppTheme.secondaryText,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.disabledText,
            ),
          ),
          const Spacer(),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: const Icon(
                CupertinoIcons.plus,
                size: 14,
                color: AppTheme.secondaryText,
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
    final name = widget.path.split(Platform.pathSeparator).last;

    return GestureDetector(
      onSecondaryTapUp: (details) {
        showMenu<String>(
          context: context,
          color: AppTheme.elevatedSurface,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx + 1,
            details.globalPosition.dy + 1,
          ),
          items: [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.white70),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.white70)),
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
                color: widget.selected ? AppTheme.selected : Colors.transparent,
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
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: widget.selected ? Colors.white : AppTheme.accent,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.folder,
                    color: widget.selected ? Colors.white : AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: widget.selected
                            ? Colors.white
                            : AppTheme.secondaryText,
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
                        color: Colors.transparent,
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
                          const Icon(
                            CupertinoIcons.doc_text,
                            color: AppTheme.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                color: AppTheme.secondaryText,
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
