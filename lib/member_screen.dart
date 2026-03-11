import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'member_model.dart';
import 'add_member_screen.dart';

class MemberScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<Member> members = [];

  loadData() async {
    members = await DBHelper.instance.getAll();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hội CCB xã Đức Hoà")),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final m = members[index];
          return ListTile(
            title: Text(m.hoTen),
            subtitle: Text("${m.namSinh} - ${m.chiHoi}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await DBHelper.instance.delete(m.id!);
                loadData();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddMemberScreen()));
          loadData();
        },
      ),
    );
  }
}