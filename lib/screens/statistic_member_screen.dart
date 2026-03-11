import 'package:flutter/material.dart';
import 'statistic_list_screen.dart';
import 'statistic_group_screen.dart';
class StatisticMemberScreen extends StatelessWidget {

  Widget menu(
      BuildContext context,
      String title,
      String field){

    return Card(

      child: ListTile(

        leading: Icon(Icons.bar_chart),

        title: Text(title),

        trailing: Icon(Icons.arrow_forward_ios),

        onTap:(){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StatisticGroupScreen(
                title: title,
                field: field,
              ),
            ),
          );

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: Text("Thông tin khác"),
      ),

      body: ListView(

        padding: EdgeInsets.all(12),

        children: [

          menu(context,"Lý luận chính trị","trinh_do_llct"),

          menu(context,"Chuyên môn","trinh_do_chuyen_mon"),

          menu(context,"Học vấn","trinh_do_hoc_van"),

          menu(context,"Chức vụ hội","chuc_vu_hoi"),

          menu(context,"Khen thưởng","khen_thuong"),

          menu(context,"Kháng chiến","tham_gia_khang_chien"),

          menu(context,"Cấp bậc","cap_bac_truoc_xuat_ngu"),

          menu(context,"Khác","ghi_chu"),

        ],
      ),
    );
  }
}