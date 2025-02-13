

import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';
import '../entity/ImageAttachment.dart';

class ImageAttachmentDao{

  Box<ImageAttachment> imageAttachmentBox;

  ImageAttachmentDao(this.imageAttachmentBox);

  List<ImageAttachment> getFavoriteThreadList(Discuz discuz){
    List<ImageAttachment> attachmentList = imageAttachmentBox.values.where((element) => element.discuz == discuz).toList();
    // desc time
    attachmentList.sort((a,b) => -a.updateAt.compareTo(b.updateAt));
    return attachmentList;
  }

  ImageAttachment? findImageAttachmentByDiscuzAndAid(Discuz discuz, String aid){
    if(imageAttachmentBox.values.where((element) => element.discuz == discuz && element.aid == aid).isNotEmpty){
      return imageAttachmentBox.values.where((element) => element.discuz == discuz && element.aid == aid).first;
    }
    else{
      return null;
    }
  }

  Future<int> insertImageAttachment(ImageAttachment imageAttachment){
    return imageAttachmentBox.add(imageAttachment);
  }

  Future<void> insertImageAttachmentWithKey(dynamic key,ImageAttachment imageAttachment){
    return imageAttachmentBox.put(key,imageAttachment);
  }
}