import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoService {

  /// thư mục lưu ảnh hội viên
  static Future<Directory> photoDir() async {

    final dir =
        await getApplicationDocumentsDirectory();

    Directory photos =
        Directory("${dir.path}/photos");

    if (!photos.existsSync()) {
      photos.createSync(recursive: true);
    }

    return photos;
  }

  /// lấy file ảnh theo id
  static Future<File> getPhoto(int id) async {

    final photos = await photoDir();

    return File("${photos.path}/$id.jpg");
  }
}