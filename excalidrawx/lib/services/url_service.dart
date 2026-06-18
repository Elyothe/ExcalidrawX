import 'package:flutter/material.dart';

class UrlService {
  static final UrlService _instance = UrlService._();
  UrlService._();

  factory UrlService() => _instance;

  String get defaultUrl => 'https://excalidraw.com/';

  Future<String> resolveUrl(BuildContext context, String? path) async {
    if (path == null) {
      return defaultUrl;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suffix = isDark ? '&theme=dark' : '&theme=light';

    return '$defaultUrl$path$suffix';
  }

  Future<bool> validateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
}
