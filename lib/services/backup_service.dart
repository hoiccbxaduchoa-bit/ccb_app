import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class BackupService {

static Future<String> createBackup() async {

final appDir = await getApplicationDocumentsDirectory();

final dbFile = File(p.join(appDir.path, "member.db"));

final photosDir = Directory(p.join(appDir.path, "photos"));

final zipPath = p.join(appDir.path, "ccb_backup.zip");

final encoder = ZipFileEncoder();
encoder.create(zipPath);

if (await dbFile.exists()) {
  encoder.addFile(dbFile);
}

if (await photosDir.exists()) {
  encoder.addDirectory(photosDir);
}

encoder.close();

return zipPath;


}

}
