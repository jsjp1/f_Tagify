import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/delete_alert.dart';

void articleInstanceEditBottomModal(BuildContext context, Article article) {
  final provider = Provider.of<TagifyProvider>(context, listen: false);

  showModalBottomSheet(
    backgroundColor: whiteBackgroundColor,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Wrap(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
            child: ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.download),
              ),
              title: GlobalText(
                localizeText: "article_edit_modal_download",
                textSize: 17.0,
                isBold: true,
              ),
              onTap: () async {
                // TODO: 게시물 저장
              },
            ),
          ),
          // 게시물 수정
          provider.loginResponse!["id"] == article.userId
              ? Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                  child: ListTile(
                    leading: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.edit),
                    ),
                    title: GlobalText(
                      localizeText: "article_edit_modal_edit",
                      textSize: 17.0,
                      isBold: true,
                    ),
                    onTap: () async {
                      // TODO: 게시물 수정
                    },
                  ),
                )
              : SizedBox.shrink(),
          // 게시물 삭제
          provider.loginResponse!["id"] == article.userId
              ? Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                  child: ListTile(
                    leading: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.delete, color: mainColor),
                    ),
                    title: GlobalText(
                      localizeText: "article_edit_modal_delete",
                      textSize: 17.0,
                      textColor: mainColor,
                      isBold: true,
                    ),
                    onTap: () async {
                      bool reallyDelete = false;
                      Navigator.pop(context);
                      reallyDelete = await showDeleteAlert(context);

                      if (reallyDelete == false) {
                        return;
                      }

                      final ApiResponse<int> response = await deleteArticle(
                          provider.loginResponse!["id"], article.id);

                      await provider.fetchArticles();
                    },
                  ),
                )
              : SizedBox.shrink(),
          const SizedBox(height: 100.0),
        ],
      );
    },
  );
}
