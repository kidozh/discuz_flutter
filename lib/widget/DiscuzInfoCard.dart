import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:flutter/material.dart';

class DiscuzInfoCard extends StatelessWidget{
  Discuz? discuz;

  DiscuzInfoCard(this.discuz);
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(discuz != null){
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4),
              child: ListTile(
                title: Text(discuz!.siteName),
                subtitle: Text(discuz!.baseURL),

              ),
            ),
            OutlinedButton(onPressed: (){

            },
                child: Text("选择论坛和用户"),

            )
          ],
        )
      );
    }
    else{
      return Container(
        child: Column(
          children: [
            Text("还没有一个论坛，尝试添加一个？"),
            ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddDiscuzPage()));
                },
                child: Text("开始添加一个论坛")
            )
          ],
        ),
      );
    }

  }
}