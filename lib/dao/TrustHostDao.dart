import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:hive/hive.dart';


class TrustHostDao{
  Box<TrustHost> trustHostBox;

  TrustHostDao(this.trustHostBox);

  List<TrustHost> findAllTrustHosts(){
    return trustHostBox.values.toList();
  }

  // Stream<List<TrustHost>> findAllTrustHostsStream(){
  //   return trustHostBox.watch().map((event) => trustHostBox.values.toList());
  // }

  Future<int> insertTrustHost(TrustHost trustHost){
    return trustHostBox.add(trustHost);
  }

  Future<void> deleteTrustHost(TrustHost trustHost) async{
    return trustHostBox.values.where((element) => element == trustHost).forEach((element) {
      trustHostBox.delete(trustHost.key);
    });
  }

  TrustHost? findTrustHostByName(String host){
    if(trustHostBox.values.where((element) => element.host == host).isNotEmpty){
      return trustHostBox.values.where((element) => element.host == host).first;
    }
    else{
      return null;
    }
  }

}