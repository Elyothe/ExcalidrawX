import 'dart:convert';

import 'package:excalidrawx/presentation/bloc/excalidraw/excalidraw_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExcalidrawScreen extends StatefulWidget {
  final ValueNotifier<String?> filePathNotifier;

  const ExcalidrawScreen({
    super.key,
    required this.filePathNotifier,
  });

  @override
  State<ExcalidrawScreen> createState() => _ExcalidrawScreenState();
}

class _ExcalidrawScreenState extends State<ExcalidrawScreen> {
  late final ExcalidrawBloc _excalidrawBloc;
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _excalidrawBloc = ExcalidrawBloc();
    widget.filePathNotifier.addListener(_onFilePathReceived);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
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
    widget.filePathNotifier.removeListener(_onFilePathReceived);
    _excalidrawBloc.close();
    super.dispose();
  }

  void _onFilePathReceived() {
    final filePath = widget.filePathNotifier.value;
    if (filePath == null) return;
    _excalidrawBloc.add(OnOpenFile(filePath));
  }

  Future<void> _injectScene(String content) async {
    try {
      final scene = jsonDecode(content) as Map<String, dynamic>;
      final elements = scene['elements'];

      await _controller.runJavaScript('''
      localStorage.setItem(
        "excalidraw",
        ${jsonEncode(jsonEncode(elements))}
      );
      window.location.reload();
    ''');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur lors de l'ouverture du fichier";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _excalidrawBloc,
      child: BlocListener<ExcalidrawBloc, ExcalidrawState>(
        listenWhen: (previous, current) =>
            current.fileContentToOpen != null &&
            previous.fileContentToOpen != current.fileContentToOpen,
        listener: (context, state) {
          _injectScene(state.fileContentToOpen!);
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
