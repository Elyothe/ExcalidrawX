import 'dart:async';
import 'dart:convert';

import 'package:excalidrawx/presentation/bloc/excalidraw/excalidraw_bloc.dart';
import 'package:excalidrawx/presentation/model/opened_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExcalidrawScreen extends StatefulWidget {
  final ValueNotifier<OpenedFile?> fileNotifier;
  final ValueNotifier<String?> libraryNotifier;

  const ExcalidrawScreen({
    super.key,
    required this.fileNotifier,
    required this.libraryNotifier,
  });

  @override
  State<ExcalidrawScreen> createState() => _ExcalidrawScreenState();
}

class _ExcalidrawScreenState extends State<ExcalidrawScreen> {
  late final ExcalidrawBloc _excalidrawBloc;
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autosaveTimer;
  bool _isPageLoaded = false;
  List<dynamic>? _pendingSceneElements;
  String? _pendingLibraryUrl;

  @override
  void initState() {
    super.initState();
    _excalidrawBloc = ExcalidrawBloc();
    widget.fileNotifier.addListener(_onFileReceived);
    widget.libraryNotifier.addListener(_onLibraryReceived);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _isPageLoaded = false;
            _autosaveTimer?.cancel();
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            _isPageLoaded = true;

            // Handle pending scene
            if (_pendingSceneElements != null) {
              _injectScene(_pendingSceneElements!);
            }

            // Handle pending library URL
            if (_pendingLibraryUrl != null) {
              final libUrl = _pendingLibraryUrl!;
              _pendingLibraryUrl = null;
              await _controller.runJavaScript('''
                window.location.hash = "#addLibrary=" + ${jsonEncode(libUrl)};
              ''');
            }

            _startAutosaveTimer();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://excalidraw.com/'));
  }

  @override
  void dispose() {
    widget.fileNotifier.removeListener(_onFileReceived);
    widget.libraryNotifier.removeListener(_onLibraryReceived);
    _autosaveTimer?.cancel();
    _excalidrawBloc.close();
    super.dispose();
  }

  Future<void> _onFileReceived() async {
    final openedFile = widget.fileNotifier.value;
    if (openedFile == null) return;

    await _saveCurrentBeforeSwitch(openedFile);

    _excalidrawBloc.add(OnOpenFile(
      openedFile.path,
      elements: openedFile.elements,
    ));
  }

  Future<void> _onLibraryReceived() async {
    final url = widget.libraryNotifier.value;
    if (url == null || url.isEmpty) return;
    await _importLibraryFromUrl(url);
    widget.libraryNotifier.value = null;
  }

  Future<void> _saveCurrentBeforeSwitch(OpenedFile openedFile) async {
    if (!_isPageLoaded) return;
    final currentPath = _excalidrawBloc.currentFilePath;
    if (currentPath == null || currentPath == openedFile.path) return;

    final result = await _getDrawerStorage();
    if (result != null) {
      _excalidrawBloc.add(OnSaveFile(result));
    }
  }

  Future<Object?> _getDrawerStorage() {
    return _controller.runJavaScriptReturningResult(
      'localStorage.getItem("excalidraw")',
    );
  }


Future<void> _importLibraryFromUrl(String url) async {
  if (!_isPageLoaded) {
    _pendingLibraryUrl = url;
    return;
  }
  _pendingLibraryUrl = null;
  await _controller.runJavaScript('''
      window.location.hash = "#addLibrary=" + ${jsonEncode(url)};
    ''');
}

Future<void> _injectScene(List<dynamic> elements) async {
    if (!_isPageLoaded) {
      _pendingSceneElements = elements;
      return;
    }
    _pendingSceneElements = null;
    await _controller.runJavaScript('''
      localStorage.setItem(
        "excalidraw",
        ${jsonEncode(jsonEncode(elements))}
      );
      window.location.reload();
    ''');
  }

  void _startAutosaveTimer() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autosaveTick(),
    );
  }

  Future<void> _autosaveTick() async {
    if (!_isPageLoaded) return;

    final result = await _getDrawerStorage();
    if (result != null) {
      _excalidrawBloc.add(OnSaveFile(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _excalidrawBloc,
      child: BlocListener<ExcalidrawBloc, ExcalidrawState>(
        listenWhen: (previous, current) =>
            (current.elements != null &&
                previous.elements != current.elements) ||
            (current.status == ExcalidrawStatus.failure &&
                previous.status != ExcalidrawStatus.failure),
        listener: (context, state) {
          if (state.elements != null) {
            _injectScene(state.elements!);
          } else if (state.status == ExcalidrawStatus.failure &&
              state.errorMessage != null) {
            setState(() {
              _errorMessage = state.errorMessage;
            });
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Error: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
