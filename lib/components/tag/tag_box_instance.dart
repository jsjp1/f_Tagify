import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/tag/tag_color_picker.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/utils/util.dart';

class TagBoxInstance extends StatelessWidget {
  final Tag? tag;
  final GestureTapCallback onTap;

  const TagBoxInstance({super.key, required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * (0.47);
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 우측 상단 튀어나온 부분
          tag != null
              ? Positioned(
                  right: 5.0,
                  top: 5.0,
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [tag!.color, whiteBackgroundColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          // circular border 상자
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: boxWidth * (0.85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: whiteBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: contentInstanceBoxShadowColor,
                        blurRadius: 5.0,
                        spreadRadius: 0.01,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: GlobalText(
                      localizeText: tag?.tagName ?? "+",
                      textSize: 17.0,
                      isBold: true,
                      localization: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // 태그 폴더 수정 버튼
                tag != null
                    ? Positioned(
                        top: -8.0,
                        right: -12.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          icon: Icon(Icons.more_vert_sharp),
                          onPressed: () {
                            // 태그 폴더 수정 바텀 모달
                            showModalBottomSheet(
                              backgroundColor: whiteBackgroundColor,
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              builder: (BuildContext context) {
                                return Wrap(
                                  children: [
                                    // 태그 색상 수정
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child:
                                              Icon(Icons.color_lens_outlined),
                                        ),
                                        title: GlobalText(
                                          localizeText:
                                              "tag_box_instance_change_color",
                                          textSize: 17.0,
                                          isBold: true,
                                        ),
                                        onTap: () async {
                                          await themeColorChange(
                                            context,
                                            provider,
                                            tag!.id,
                                            tag!.tagName,
                                          );
                                        },
                                      ),
                                    ),

                                    // 태그 내용 공유하기 위한 base64 인코딩
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(CupertinoIcons.share),
                                        ),
                                        title: GlobalText(
                                          localizeText:
                                              "tag_box_instance_encoding",
                                          textSize: 17.0,
                                          isBold: true,
                                        ),
                                        onTap: () async {
                                          List<Content> tagContents = provider
                                              .getTagContents(tag!.tagName);

                                          Map<String, dynamic> contentListMap =
                                              contentListToMap(tagContents);
                                          String encodedContentList =
                                              encodeTaggedContentsToBase64(
                                                  contentListMap);

                                          Clipboard.setData(ClipboardData(
                                                  text: encodedContentList))
                                              .then(
                                            (_) {
                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      snackBarColor,
                                                  content: GlobalText(
                                                      localizeText:
                                                          "tag_box_instance_clipboard_save_success",
                                                      textSize: 15.0),
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),

                                    // 태그 폴더 수정
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(Icons.edit),
                                        ),
                                        title: GlobalText(
                                          localizeText: "tag_box_instance_edit",
                                          textSize: 17.0,
                                          isBold: true,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          // TODO: 수정 로직 추가
                                        },
                                      ),
                                    ),

                                    // 태그 삭제
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(CupertinoIcons.delete,
                                              color: mainColor),
                                        ),
                                        title: GlobalText(
                                          localizeText:
                                              "tag_box_instance_delete",
                                          textSize: 17.0,
                                          textColor: mainColor,
                                          isBold: true,
                                        ),
                                        onTap: () async {
                                          // TODO: 삭제 전 모달 띄우기
                                          final response = await provider
                                              .pvDeleteTag(tag!.tagName);

                                          if (response == false) {
                                            // TODO: dio error 처리 완벽하게 해야됨...
                                            // 안에 컨텐츠 있어서 못 지울경우.. 실패모달 띄우기
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: snackBarColor,
                                                content: GlobalText(
                                                    localizeText:
                                                        "tag_box_instance_cant_delete",
                                                    textSize: 15.0),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 100.0),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
