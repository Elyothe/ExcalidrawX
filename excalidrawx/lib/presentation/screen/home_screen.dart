import 'dart:typed_data';

import 'package:excalidrawx/presentation/bloc/home/home_bloc.dart';
import 'package:excalidrawx/presentation/screen/excalidraw_screen.dart';
import 'package:excalidrawx/presentation/widget/macos_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: MacosLayout(
                    onSave: () {
                      final data = Uint8List(0);
                      final name = 'excalidraw-${DateTime.now().millisecondsSinceEpoch}';
                      context.read<HomeBloc>().add(OnCreateDrawer(data, name: name));
                    },
                  ),
                ),
                const Expanded(
                  child: ExcalidrawScreen(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}