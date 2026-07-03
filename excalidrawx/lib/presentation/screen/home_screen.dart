import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/presentation/bloc/home/home_bloc.dart';
import 'package:excalidrawx/presentation/model/opened_file.dart';
import 'package:excalidrawx/presentation/screen/excalidraw_screen.dart';
import 'package:excalidrawx/presentation/widget/macos_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';

import '../widget/layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  final ValueNotifier<OpenedFile?> _openedFileNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _libraryNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
    _homeBloc.add(OnLoadSavedFolders());
    _homeBloc.add(OnRestoreLibrary());
  }

  @override
  void dispose() {
    _openedFileNotifier.dispose();
    _libraryNotifier.dispose();
    _homeBloc.close();
    super.dispose();
  }

  Future<void> _onOpenFile() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Ouvrir un fichier Excalidraw',
      type: FileType.custom,
      allowedExtensions: ['excalidraw'],
    );
    if (result == null) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    _openedFileNotifier.value = OpenedFile(filePath);
  }

  Future<void> _onImportLibrary() async {
    final urlController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const Icon(CupertinoIcons.book, size: 48),
        title: const Text('Importer une library via URL'),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Collez l'URL de la library Excalidraw :"),
            const SizedBox(height: 12),
            MacosTextField(
              placeholder: 'https://...',
              controller: urlController,
            ),
          ],
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          child: const Text('Importer'),
          onPressed: () => Navigator.of(context).pop(urlController.text),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
    );

    if (url != null && url.trim().isNotEmpty) {
      _homeBloc.add(OnImportLibrary(url.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.openedFilePath != current.openedFilePath ||
            previous.openedElements != current.openedElements ||
            previous.libraryUrl != current.libraryUrl,
        listener: (context, state) {
          if (state.openedFilePath != null) {
            _openedFileNotifier.value = OpenedFile(
              state.openedFilePath!,
              elements: state.openedElements,
            );
          }
          if (state.libraryUrl != null) {
            _libraryNotifier.value = state.libraryUrl;
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        return Layout(
                          onSave: () {
                            final data = Uint8List(0);
                            final name = 'excalidraw-${DateTime.now().millisecondsSinceEpoch}';
                            context.read<HomeBloc>().add(OnCreateDrawer(data, name: name));
                          },
                          onOpenFile: _onOpenFile,
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
                          onImportLibrary: _onImportLibrary,
                          onDeleteFolder: (path) {
                            context.read<HomeBloc>().add(OnDeleteFolder(path));
                          },
                          folderFiles: state.folderFiles,
                          onOpenDrawerFile: (path) {
                            context.read<HomeBloc>().add(OnOpenDrawerFile(path));
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ExcalidrawScreen(
                      fileNotifier: _openedFileNotifier,
                      libraryNotifier: _libraryNotifier,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
