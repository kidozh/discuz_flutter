

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
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
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(_attachment.filename),
            subtitle: Text(_attachment.attachmentSizeString),
          ),
          CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
          )
        ],
      ),
    );
  }

}