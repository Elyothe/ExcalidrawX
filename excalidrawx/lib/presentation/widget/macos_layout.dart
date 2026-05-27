import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosLayout extends StatefulWidget {
  const MacosLayout({super.key});

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
                label: Text('Page One'),
              ),
              SidebarItem(
                label: Text('Page Two'),
              ),
            ],
          );
        },
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
      case 1:
        return const Center(child: Text('Page Two Content'));
      default:
        return const SizedBox.shrink();
    }
  }
}