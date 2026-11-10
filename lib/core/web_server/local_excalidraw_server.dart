import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:flutter/services.dart';

import 'package:excalidrawx/core/logger/logger_setup.dart';

class LocalExcalidrawServer {
  static const _assetPrefix = 'assets/excalidraw/';

  HttpServer? _server;
  Set<String> _assets = const {};

  Future<Either<Object, Uri>> start() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets = manifest
          .listAssets()
          .where((asset) => asset.startsWith(_assetPrefix))
          .toSet();

      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(_handleRequest);

      final uri = Uri.parse('http://127.0.0.1:${_server!.port}/');
      logger.i('Local Excalidraw server started: $uri');
      return right(uri);
    } catch (error) {
      logger.e('Failed to start local Excalidraw server: $error');
      return left(error);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    var path = request.uri.path;
    if (path == '/') path = '/index.html';

    if (path.contains('..')) {
      await _respond(request, HttpStatus.forbidden);
      return;
    }

    final assetPath = '$_assetPrefix${path.substring(1)}';
    if (!_assets.contains(assetPath)) {
      await _respond(request, HttpStatus.notFound);
      return;
    }

    try {
      final data = await rootBundle.load(assetPath);
      request.response.headers.contentType = _contentType(path);
      request.response.add(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      await request.response.close();
    } catch (error) {
      logger.e('Failed to serve local Excalidraw asset $assetPath: $error');
      await _respond(request, HttpStatus.internalServerError);
    }
  }

  ContentType _contentType(String path) {
    if (path.endsWith('.html')) return ContentType.html;
    if (path.endsWith('.js')) {
      return ContentType.parse('application/javascript; charset=utf-8');
    }
    if (path.endsWith('.css')) return ContentType('text', 'css');
    if (path.endsWith('.json')) return ContentType.json;
    if (path.endsWith('.svg')) return ContentType('image', 'svg+xml');
    if (path.endsWith('.png')) return ContentType('image', 'png');
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return ContentType('image', 'jpeg');
    }
    if (path.endsWith('.woff2')) return ContentType('font', 'woff2');
    return ContentType.binary;
  }

  Future<void> _respond(HttpRequest request, int statusCode) async {
    request.response.statusCode = statusCode;
    await request.response.close();
  }

  Future<Either<Object, Unit>> dispose() async {
    try {
      await _server?.close(force: true);
      _server = null;
      logger.i('Local Excalidraw server stopped');
      return right(unit);
    } catch (error) {
      logger.e('Failed to stop local Excalidraw server: $error');
      return left(error);
    }
  }
}
