import 'package:flutter/cupertino.dart';
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
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
                Navigator.pop(context);

                // 저장할 태그 이름 입력 받기
                // TODO: 이부분 analyze set tag랑 똑같은데, 추후 분리
                String? tagName = await showModalBottomSheet<String>(
                  backgroundColor: whiteBackgroundColor,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0)),
                  ),
                  builder: (BuildContext context) {
                    TextEditingController tagNameController =
                        TextEditingController(text: article.title);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  30.0, 20.0, 0.0, 0.0),
                              child: GlobalText(
                                localizeText: "article_edit_modal_tag_input",
                                textSize: 22.0,
                                isBold: true,
                                localization: true,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 100.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    autocorrect: false,
                                    autofocus: true,
                                    cursorColor: mainColor,
                                    controller: tagNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide(
                                            color: mainColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide(
                                            color: mainColor, width: 2.0),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                            CupertinoIcons.clear_circled_solid),
                                        onPressed: () {
                                          tagNameController.clear();
                                        },
                                      ),
                                    ),
                                    onSubmitted: (String text) {
                                      Navigator.pop(context, text);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25.0),
                        ],
                      ),
                    );
                  },
                );

                if (tagName == null || tagName.isEmpty) {
                  return;
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
}
