

import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:hive_ce/hive.dart';

import '../entity/AiRule.dart';

class AiRuleDao{
  Box<AiRule> aiRuleBox;

  AiRuleDao(this.aiRuleBox);

  Future<int> insertAiRule(AiRule aiRule){
    return aiRuleBox.add(aiRule);
  }

  Future<void> putAiRule(dynamic key, AiRule aiRule){
    return aiRuleBox.put(key, aiRule);
  }

  Future<void> deleteAiRule(AiRule aiRule) async{
    aiRuleBox.values.where((element) => element == aiRule).forEach((element) {

      aiRuleBox.delete(element.key);
    });

  }

  // Future<void> deleteBlockUserByUid(int uid, Discuz discuz) async{
  //   blockUserBox.values.where((element) => element.uid == uid && element.discuz == discuz).forEach((element) {
  //
  //     blockUserBox.delete(element.key);
  //   });
  //
  // }


  Stream<List<AiRule>> getAllAiRuleListStream(){
    return aiRuleBox.watch().map((event) => aiRuleBox.values.toList());
  }

  List<AiRule> getAllAiRuleList(){
    List<AiRule> aiRuleList = aiRuleBox.values.toList();
    aiRuleList.sort((a,b) => - a.updateTime.compareTo(b.updateTime));
    return aiRuleList;
  }





}