import 'package:excalidrawx/services/url_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExcalidrawScreen extends StatefulWidget {
  final String? initialUrl;

  const ExcalidrawScreen({super.key, this.initialUrl});

  @override
  State<ExcalidrawScreen> createState() => _ExcalidrawScreenState();
}

class _ExcalidrawScreenState extends State<ExcalidrawScreen> {
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
              ),
            ),
        ],
      ),
    );
  }
}
