import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/presentation/bloc/home/home_bloc.dart';
import 'package:excalidrawx/presentation/screen/excalidraw_screen.dart';
import 'package:excalidrawx/presentation/widget/macos_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
    _homeBloc.add(OnLoadSavedFolders());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Row(
              children: [
                  SizedBox(
                    width: 220,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        return MacosLayout(
                          onSave: () {
                            final data = Uint8List(0);
                            final name = 'excalidraw-${DateTime.now().millisecondsSinceEpoch}';
                            context.read<HomeBloc>().add(OnCreateDrawer(data, name: name));
                          },
                          onCreateFolder: () async {
                            final selectedPath = await FilePicker.getDirectoryPath(
                              dialogTitle: 'Choisir l\'emplacement du dossier',
                            );
                            if (selectedPath == null) return;
                            final name = 'folder-${DateTime.now().millisecondsSinceEpoch}';
                            final base = Directory(selectedPath);
                            context.read<HomeBloc>().add(OnCreateFolder(name, base: base));
                          },
                          onSelectFolder: () {
                            context.read<HomeBloc>().add(OnSelectFolder());
                          },
                          listFolder: state.savedFolders,
                        );
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