import 'package:logger/logger.dart';

import 'file_log_output.dart';

Logger? _logger;
FileLogOutput? _fileOutput;

Logger get logger => _logger!;

Future<void> setupLogger({String? directory}) async {
  _fileOutput = FileLogOutput(directory: directory);
  await _fileOutput!.initialize();

  _logger = Logger(
    output: MultiOutput([ConsoleOutput(), _fileOutput!]),
  );
}
