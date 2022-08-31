

import 'package:hive/hive.dart';

import '../entity/Draft.dart';

class DraftDao{
  Box<Draft> draftBox;

  DraftDao(this.draftBox);

  Future<int> insertDraft(Draft draft){
    return draftBox.add(draft);
  }

  Future<Draft?> insertDraftAndReturnInsertObj(Draft draft) async{
    if(draft.key == null){
      int index = await draftBox.add(draft);
      Draft? savedDraft = await draftBox.getAt(index);
      return savedDraft;
    }
    else{
      await draftBox.put(draft.key, draft);
      return draft;
    }



  }

  Draft? getDraftByIndex(int index){
    return draftBox.get(index);
  }

  Future<void> deleteDraft(Draft draft){
    return draftBox.delete(draft);

  }
}