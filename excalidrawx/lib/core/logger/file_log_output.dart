import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  static final _ansiEscape = RegExp(r'\x1B\[[0-9;]*m');

  final String fileName;
  final int maxFileSizeBytes;
  final String? directory;

  IOSink? _sink;
  File? _logFile;
  int _currentSize = 0;

  FileLogOutput({
    this.fileName = 'app.log',
    this.maxFileSizeBytes = 5 * 1024 * 1024,
    this.directory,
  });

  Future<void> initialize() async {
    final base = directory ?? (await getApplicationDocumentsDirectory()).path;
    final logDir = Directory('$base/logs');
    await logDir.create(recursive: true);

    _logFile = File('${logDir.path}/$fileName');
    if (await _logFile!.exists()) {
      _currentSize = await _logFile!.length();
    }

    _sink = _logFile!.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    if (_sink == null) return;

    try {
      for (var line in event.lines) {
        final clean = line.replaceAll(_ansiEscape, '');
        _sink!.writeln(clean);
        _currentSize += clean.length + 1;

        if (_currentSize >= maxFileSizeBytes) {
          _rotate();
        }
      }
      _sink?.flush();
    } catch (_) {}
  }

  void _rotate() {
    _sink?.close();
    final logDir = _logFile!.parent;
    final rotated = File('${logDir.path}/$fileName.1');
    if (rotated.existsSync()) {
      rotated.deleteSync();
    }
    _logFile!.renameSync(rotated.path);
    _logFile = File('${logDir.path}/$fileName');
    _sink = _logFile!.openWrite(mode: FileMode.append);
    _currentSize = 0;
  }

  Future<void> close() async {
    await _sink?.close();
  }
}
