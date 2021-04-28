

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:flutter/material.dart';

class AttachmentWidget extends StatelessWidget{
  Discuz _discuz;
  Attachment _attachment;

  AttachmentWidget(this._discuz,this._attachment);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(["jpg","png","svg","bmp","gif"].contains(_attachment.ext.toLowerCase()));
    print(_attachment.ext.toLowerCase());
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.attachment),
            title: Text(_attachment.filename),
            subtitle: Text(_attachment.attachmentSizeString),
            trailing: Badge(
              badgeContent: Text(_attachment.downloads.toString(),style: TextStyle(color: Colors.white),),
              child: Icon(Icons.file_download),
            ),
          ),
          CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                  icon: Icon(Icons.file_download),
                  onPressed: (){

              }, label: Text(S.of(context).downloadAttachment)),
              if(["jpg","png","svg","bmp","gif"].contains(_attachment.ext.toLowerCase()))
              TextButton.icon(
                  icon: Icon(Icons.fullscreen),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FullImagePage(_attachment.getAttachmentRealUrl(_discuz)))
                    );
              }, label: Text(S.of(context).watchPictureInFullScreen))
            ],
          )
        ],
      ),
    );
  }

}