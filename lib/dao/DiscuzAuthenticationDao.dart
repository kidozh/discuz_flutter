

import 'package:hive/hive.dart';

import '../entity/DiscuzAuthentication.dart';

class DiscuzAuthenticationDao{
  Box<DiscuzAuthentication> discuzAuthenticationBox;

  DiscuzAuthenticationDao(this.discuzAuthenticationBox);

  Future<int> insertDiscuzAuthentication(DiscuzAuthentication discuzAuthentication) async{
    // check with discuz first
    if(discuzAuthenticationBox.values.where(
            (element) => element.account == discuzAuthentication.account
                && element.discuz_host == discuzAuthentication.discuz_host).isNotEmpty){
      // replace the existing record
      DiscuzAuthentication discuzAuthenticationInRecord = discuzAuthenticationBox.values.where(
              (element) => element.account == discuzAuthentication.account
              && element.discuz_host == discuzAuthentication.discuz_host).first;
      discuzAuthenticationInRecord.password = discuzAuthentication.password;
      discuzAuthenticationInRecord.updateTime = DateTime.now();
      await discuzAuthenticationInRecord.save();
      return discuzAuthenticationInRecord.hashCode;
    }
    else{
      int id = await discuzAuthenticationBox.add(discuzAuthentication);
      return id;

    }
  }

  List<DiscuzAuthentication> getDiscuzAuthenticationListByHost(String host){
    return discuzAuthenticationBox.values.where(
            (element) => element.discuz_host == host).toList();
  }

  List<DiscuzAuthentication> getAllDiscuzAuthentications(){
    List<DiscuzAuthentication> list = discuzAuthenticationBox.values.toList();
    list.sort((a,b) => a.discuz_host.compareTo(b.discuz_host));
    return list;
  }


}