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

  Future<void> _injectScene(List<dynamic> elements) async {
    await _controller.runJavaScript('''
      localStorage.setItem(
        "excalidraw",
        ${jsonEncode(jsonEncode(elements))}
      );
      window.location.reload();
    ''');
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
