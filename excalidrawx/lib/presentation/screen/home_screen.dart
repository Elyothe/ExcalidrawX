import 'package:excalidrawx/presentation/widget/macos_layout.dart';
import 'package:flutter/material.dart';

import 'excalidraw_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 220,
            child: MacosLayout(),
          ),
          const Expanded(
            child: ExcalidrawScreen(),
          ),
        ],
      ),
    );
  }
}