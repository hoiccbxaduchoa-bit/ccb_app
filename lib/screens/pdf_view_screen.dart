import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewScreen extends StatefulWidget {

final String path;
final String title;

const PdfViewScreen({
super.key,
required this.path,
required this.title,
});

@override
State<PdfViewScreen> createState() =>
_PdfViewScreenState();
}

class _PdfViewScreenState
extends State<PdfViewScreen> {

String localPath = "";

@override
void initState() {
super.initState();
loadPdf();
}

Future loadPdf() async {


final data =
    await rootBundle.load(widget.path);

final dir =
    await getTemporaryDirectory();

final file =
    File("${dir.path}/temp.pdf");

await file.writeAsBytes(
    data.buffer.asUint8List());

setState(() {
  localPath = file.path;
});


}

@override
Widget build(BuildContext context) {


return Scaffold(

  appBar: AppBar(
    title: Text(widget.title),
  ),

  body: localPath.isEmpty
      ? Center(
          child:
              CircularProgressIndicator())
      : PDFView(
          filePath: localPath,
        ),
);


}
}
