import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onOpenFile;
  final VoidCallback onCreateFolder;
  final VoidCallback onSelectFolder;
  final Map<String, List<String>> folderFiles;
  final ValueChanged<String> onDeleteFolder;
  final ValueChanged<String> onOpenDrawerFile;

  const Layout({
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
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Row(
        children: [
          Container(
            width: 220,
            color: const Color(0xFF1A1A1A),
            child: Column(
              children: [
                if (Platform.isMacOS)
                  Container(
                    width: double.infinity,
                    height: 52,
                    color: Colors.transparent,
                  ),
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
                          onDelete: () => widget.onDeleteFolder(entry.key),
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
            ),
          ),
          Expanded(
            child: _buildPage(pageIndex),
          ),
        ],
      ),
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

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DarkButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
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
          color: selected
              ? const Color.fromRGBO(22, 105, 229, 0.749)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF4A9EFF),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFCCCCCC),
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
              color: Color(0xFF555555),
            ),
          ),
          const Spacer(),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: const Icon(
                CupertinoIcons.plus,
                size: 14,
                color: Color(0xFF666666),
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
          color: const Color(0xFF2A2A2A),
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
                color: widget.selected
                    ? const Color.fromRGBO(22, 105, 229, 0.749)
                    : Colors.transparent,
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
                      color: widget.selected
                          ? Colors.white
                          : const Color(0xFF4A9EFF),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.folder,
                    color: widget.selected
                        ? Colors.white
                        : const Color(0xFF4A9EFF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: widget.selected
                            ? Colors.white
                            : const Color(0xFFCCCCCC),
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
                            color: Color(0xFF4A9EFF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                color: Color(0xFFCCCCCC),
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
