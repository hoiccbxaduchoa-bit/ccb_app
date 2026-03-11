import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'db_service.dart';
import 'photo_service.dart';

class SyncService {

static Future<bool> syncBackup() async {


try {

  /// =========================
  /// CHỌN FILE ZIP
  /// =========================

  FilePickerResult? result =
      await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );

  if (result == null) return false;

  File zipFile = File(result.files.single.path!);

  /// =========================
  /// THƯ MỤC APP
  /// =========================

  Directory appDir =
      await getApplicationDocumentsDirectory();

  String extractPath =
      "${appDir.path}/ccb_sync";

  Directory syncDir = Directory(extractPath);

  /// XÓA THƯ MỤC SYNC CŨ NẾU CÓ
  if (syncDir.existsSync()) {
    syncDir.deleteSync(recursive: true);
  }

  /// TẠO THƯ MỤC MỚI
  syncDir.createSync(recursive: true);

  /// =========================
  /// GIẢI NÉN FILE ZIP
  /// =========================

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {

    final filename = "$extractPath/${file.name}";

    if (file.isFile) {

      final outFile = File(filename)
        ..createSync(recursive: true);

      outFile.writeAsBytesSync(file.content);

    } else {

      Directory(filename)
          .createSync(recursive: true);

    }

  }

  /// =========================
  /// ĐÓNG DATABASE
  /// =========================

  await DBService.closeDB();

  /// =========================
  /// COPY DATABASE
  /// =========================

  File dbSource =
      File("$extractPath/members.db");

  if (!dbSource.existsSync()) {
    print("SYNC ERROR: members.db not found");
    return false;
  }

  String dbPath =
      await DBService.dbPath();

  File dbFile = File(dbPath);

  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  await dbSource.copy(dbPath);

  /// =========================
  /// COPY PHOTOS
  /// =========================

  Directory photoSource =
      Directory("$extractPath/photos");

  if (photoSource.existsSync()) {

    Directory photosDir =
        await PhotoService.photoDir();

    /// XÓA ẢNH CŨ
    for (var f in photosDir.listSync()) {
      if (f is File) {
        f.deleteSync();
      }
    }

    /// COPY ẢNH MỚI
    for (var f in photoSource.listSync()) {

      if (f is File) {

        String name =
            f.uri.pathSegments.last;

        await f.copy("${photosDir.path}/$name");

      }

    }

  }

  print("SYNC SUCCESS");

  return true;

} catch (e) {

  print("SYNC ERROR: $e");

  return false;

}


}

}
