import 'dart:io';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final Map data;
  final Function onDelete;

  MemberCard({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: data['image'] != null
            ? CircleAvatar(
                backgroundImage: FileImage(File(data['image'])),
              )
            : Icon(Icons.person),
        title: Text(data['hoTen']),
        subtitle: Text("${data['namSinh']} - ${data['chiHoi']}"),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDelete(),
        ),
      ),
    );
  }