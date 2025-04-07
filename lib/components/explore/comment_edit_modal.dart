import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/delete_alert.dart';

Future<bool> commentEditBottomModal(
    BuildContext context, Comment comment) async {
  final provider = Provider.of<TagifyProvider>(context, listen: false);

  final result = await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return Wrap(
        children: [
          // 댓글 삭제
          provider.loginResponse!["id"] == comment.userId
              ? Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                  child: ListTile(
                    leading: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.delete, color: mainColor),
                    ),
                    title: GlobalText(
                      localizeText: "article_edit_modal_delete", // TODO
                      textSize: 17.0,
                      textColor: mainColor,
                      isBold: true,
                    ),
                    onTap: () async {
                      final reallyDelete = await showDeleteAlert(context);

                      if (reallyDelete) {
                        await provider.pvDeleteComment(comment.id);
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pop(context, false);
                      }
                    },
                  ),
                )
              : SizedBox.shrink(),
          const SizedBox(height: 100.0),
        ],
      );
    },
  );

  return result ?? false;
}
