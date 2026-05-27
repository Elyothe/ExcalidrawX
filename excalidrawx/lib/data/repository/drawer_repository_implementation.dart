import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:file_picker/file_picker.dart';

class DrawerRepositoryImplementation implements DrawerRepository {

  /// Opens a "Save As" dialog with [name] (adds `.excalidraw` if missing).
  /// Returns the saved file path, or `null` if the user cancelled.
  @override
  Future<String?> saveFile(Uint8List data, {required String name}) async {
    final fileName = name.endsWith('.excalidraw') ? name : '$name.excalidraw';

    final path = await FilePicker.saveFile(
      dialogTitle: 'Enregistrer le fichier Excalidraw',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['excalidraw'],
    );

    if (path == null) return null;

    final file = File(path);
    await file.writeAsBytes(data);
    return path;
  }
}
