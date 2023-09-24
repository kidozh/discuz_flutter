

import 'package:hive/hive.dart';

import '../entity/DiscuzAuthentification.dart';

class DiscuzAuthentificationDao{
  Box<DiscuzAuthentification> discuzAuthentificationBox;

  DiscuzAuthentificationDao(this.discuzAuthentificationBox);

  Future<int> insertDiscuzAuthentification(DiscuzAuthentification discuzAuthentification) async{
    // check with discuz first
    if(discuzAuthentificationBox.values.where(
            (element) => element.account == discuzAuthentification.account
                && element.discuz_host == discuzAuthentification.discuz_host).isNotEmpty){
      // replace the existing record
      DiscuzAuthentification discuzAuthentificationInRecord = discuzAuthentificationBox.values.where(
              (element) => element.account == discuzAuthentification.account
              && element.discuz_host == discuzAuthentification.discuz_host).first;
      discuzAuthentificationInRecord.password = discuzAuthentification.password;
      discuzAuthentificationInRecord.updateTime = DateTime.now();
      await discuzAuthentificationInRecord.save();
      return discuzAuthentificationInRecord.hashCode;
    }
    else{
      int id = await discuzAuthentificationBox.add(discuzAuthentification);
      return id;

    }
  }

  List<DiscuzAuthentification> getDiscuzAuthentificationListByHost(String host){
    return discuzAuthentificationBox.values.where(
            (element) => element.discuz_host == host).toList();
  }


}