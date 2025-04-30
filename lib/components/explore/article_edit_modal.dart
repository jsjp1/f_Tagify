import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/delete_alert.dart';
import 'package:tagify/screens/article_edit_screen.dart';

void articleInstanceEditBottomModal(
    BuildContext context, Article article) async {
  final provider = Provider.of<TagifyProvider>(context, listen: false);

  await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          String tagName = "";
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
                    // 저장할 태그 이름 입력 받기
                    // TODO: 이부분 analyze set tag랑 똑같은데, 추후 분리
                    await setTagBottomModal(context, (String newTagName) {
                      setModalState(() {
                        tagName = newTagName;
                      });
                    });
                    Navigator.pop(context);

                    if (tagName == "") {
                      return;
                    }
                    // premium이 아닌 회원이 태그를 7개 이상만드려고 할 때 제한 + 기존에 존재하던 태그도 아닐 때
                    if (provider.tags.length == nonePremiumTagUpperBound &&
                        provider.tags.any((tag) => tag.tagName == tagName) ==
                            false) {
                      if (provider.loginResponse!["is_premium"] == false) {
                        // 프리미엄 회원이 아닌 경우
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: snackBarColor,
                            content: GlobalText(
                                localizeText: "no_premium_tag_count_error",
                                textSize: 15.0),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                    }

                    await provider.pvDownloadArticle(tagName, article.id);
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            CustomPageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return ArticleEditScreen(
                                    article: article, tagGiven: article.tags);
                              },
                            ),
                          );
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

                          String alertMessage =
                              "content_instance_really_delete_text";
                          reallyDelete =
                              await showDeleteAlert(context, alertMessage);

                          if (reallyDelete == false) {
                            return;
                          }

                          await provider.pvDeleteArticle(article.id);
                        },
                      ),
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 100.0),
            ],
          );
        },
      );
    },
  );
}
