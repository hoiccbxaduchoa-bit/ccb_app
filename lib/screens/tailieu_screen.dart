import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class TaiLieuScreen extends StatefulWidget {
  @override
  State<TaiLieuScreen> createState() => _TaiLieuScreenState();
}

class _TaiLieuScreenState extends State<TaiLieuScreen> {

  List<File> files = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// LOAD FILES TỪ THƯ MỤC APP
  loadFiles() async {

    final dir = await getApplicationDocumentsDirectory();

    Directory docs =
        Directory("${dir.path}/documents");

    if (!docs.existsSync()) {
      docs.createSync(recursive: true);
    }

    List<FileSystemEntity> list =
        docs.listSync();

    files = list
        .whereType<File>()
        .toList();

    setState(() {});
  }

  /// TẢI FILE
  pickFile() async {

    FilePickerResult? result =
        await FilePicker.platform.pickFiles();

    if (result == null) return;

    File source =
        File(result.files.single.path!);

    final dir =
        await getApplicationDocumentsDirectory();

    Directory docs =
        Directory("${dir.path}/documents");

    if (!docs.existsSync()) {
      docs.createSync(recursive: true);
    }

    String name =
        result.files.single.name;

    File dest =
        File("${docs.path}/$name");

    await source.copy(dest.path);

    loadFiles();
  }

  /// MỞ FILE
  openFile(File file) {
    OpenFilex.open(file.path);
  }

  /// XOÁ FILE
  deleteFile(int index) {

    files[index].deleteSync();

    setState(() {
      files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Tài liệu của tôi"),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: pickFile,
        icon: Icon(Icons.upload_file),
        label: Text("Tải lên"),
      ),

      body: ListView.builder(

        itemCount: files.length,

        itemBuilder: (context, index) {

          final file = files[index];

          return Card(
            child: ListTile(

              leading: Icon(
                Icons.insert_drive_file,
                color: Colors.blue,
              ),

              title: Text(
                file.path.split("/").last,
              ),

              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteFile(index);
                },
              ),

              onTap: () {
                openFile(file);
              },

            ),
          );
        },
      ),
    );
  }
}