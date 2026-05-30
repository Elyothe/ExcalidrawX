import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosLayout extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCreateFolder;
  final VoidCallback onSelectFolder;

  const MacosLayout({super.key, required this.onSave, required this.onCreateFolder, required this.onSelectFolder});

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
          return SidebarItems(
            currentIndex: pageIndex,
            scrollController: scrollController,
            itemSize: SidebarItemSize.large,
            onChanged: (i) {
              setState(() => pageIndex = i);
            },
            items: const [
              SidebarItem(
                label: Text('Accueil'),
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
                child: const Text('Enregistrer'),
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
        return const Center(child: Text('Page One Content'));
      default:
        return const SizedBox.shrink();
    }
  }
}