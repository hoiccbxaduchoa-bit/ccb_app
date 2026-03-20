import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';

class ImportService {

  static Future<bool> importZip(String zipPath) async {

    try {

      // ===== 1. GIẢI NÉN =====
      final tempDir = await getTemporaryDirectory();
      final extractPath = tempDir.path + "/ccb_import";

      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      for (final file in archive) {
        final filename = "$extractPath/${file.name}";

        if (file.isFile) {
          final outFile = File(filename);
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(file.content);
        } else {
          Directory(filename).createSync(recursive: true);
        }
      }

      // ===== 2. MỞ DB TẠM =====
      final tempDbPath = "$extractPath/members.db";
      final tempDb = await openDatabase(tempDbPath);

      final mainDb = await DBService.database();

      final data = await tempDb.query("members");

      // ===== 3. MERGE =====
      for (var row in data) {

        var uid = row["uid"];

        if (uid == null || uid.toString().isEmpty) {
          // nếu file cũ chưa có uid → bỏ qua hoặc tự tạo
          continue;
        }

        var exist = await mainDb.query(
          "members",
          where: "uid=?",
          whereArgs: [uid],
        );

        if (exist.isEmpty) {
          // thêm mới
          await mainDb.insert("members", row);
        } else {
          // cập nhật
          await mainDb.update(
            "members",
            row,
            where: "uid=?",
            whereArgs: [uid],
          );
        }
      }

      await tempDb.close();

      // ===== 4. COPY ẢNH =====
      final photoSrc = Directory("$extractPath/photos");

      if (photoSrc.existsSync()) {

        final appDir = await getApplicationDocumentsDirectory();
        final photoDest = Directory("${appDir.path}/photos");

        if (!photoDest.existsSync()) {
          photoDest.createSync(recursive: true);
        }

        for (var file in photoSrc.listSync()) {
          if (file is File) {
            final name = file.path.split('/').last;
            file.copySync("${photoDest.path}/$name");
          }
        }
      }

      return true;

    } catch (e) {

      print("IMPORT ERROR: $e");
      return false;

    }
  }
}

