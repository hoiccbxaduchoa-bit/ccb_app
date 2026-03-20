import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../services/db_service.dart';

class BackupService {

  static Future<String> createBackup() async {

    final appDir = await getApplicationDocumentsDirectory();

    // ✅ LẤY ĐÚNG DB
    final dbPath = await DBService.dbPath();
    final dbFile = File(dbPath);

    final photosDir = Directory(p.join(appDir.path, "photos"));

    final zipPath = p.join(appDir.path, "ccb_backup.zip");

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    // ===== ADD DB =====
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    } else {
      print("❌ Không tìm thấy DB: $dbPath");
    }

    // ===== ADD ẢNH =====
    if (await photosDir.exists()) {
      encoder.addDirectory(photosDir);
    }

    encoder.close();

    return zipPath;
  }
}
