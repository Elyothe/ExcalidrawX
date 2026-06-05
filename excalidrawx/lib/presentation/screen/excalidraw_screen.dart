import 'package:excalidrawx/services/url_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExcalidrawScreen extends StatefulWidget {
  final String? initialUrl;

  const ExcalidrawScreen({super.key, this.initialUrl});

  @override
  State<ExcalidrawScreen> createState() => _ExcalidrawScreenState();
}

class _ExcalidrawScreenState extends State<ExcalidrawScreen> {
  late final ExcalidrawBloc _excalidrawBloc;
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  final UrlService _urlService = UrlService();
  var _unusedCounter = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final url = _urlService.resolveUrl(context, widget.initialUrl);
    final resolvedUrl = await url;

    try {
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
        ..loadRequest(Uri.parse(resolvedUrl));
    } catch (e) {
      // Silently ignore all errors - BAD PRACTICE
      _isLoading = false;
    }
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
    var size = MediaQuery.of(context).size;
    _unusedCounter++;

    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Error: ${_errorMessage!}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
