import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/components/common/tag_container.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

Future<dynamic> setTagBottomModal(
    BuildContext context, Function(String) setState) {
  return showModalBottomSheet(
    constraints: BoxConstraints(
      minWidth: MediaQuery.of(context).size.width,
    ),
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      final provider = Provider.of<TagifyProvider>(context, listen: false);
      String selectedTagName = "";
      TextEditingController tagNameController = TextEditingController();

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 기존의 태그에서 선택
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 15.0, 0.0, 0.0),
                    child: GlobalText(
                      localizeText: "content_edit_widget_selected_tag",
                      textSize: 20.0,
                      isBold: true,
                      localization: true,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 20.0),
                              ...provider.tags.map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 15.0, 0.0, 0.0),
                                  child: TagContainer(
                                    tagName: tag.tagName,
                                    textSize: 13.0,
                                    tagColor: tag.color,
                                    isSelected: tag.tagName == selectedTagName,
                                    onTap: () async {
                                      setModalState(() {
                                        selectedTagName = tag.tagName;
                                      });
                                      tagNameController.text = selectedTagName;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: const Divider(height: 0.5),
                ),
                // 새로운 태그 지정
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 10.0, 0.0, 0.0),
                    child: GlobalText(
                      localizeText: "content_edit_widget_save_tag_name",
                      textSize: 20.0,
                      isBold: true,
                      localization: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          autocorrect: false,
                          autofocus: true,
                          cursorColor: mainColor,
                          controller: tagNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: mainColor, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: mainColor, width: 2.0),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                  CupertinoIcons.clear_circled_solid),
                              onPressed: () {
                                tagNameController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          onSubmitted: (String newTag) {
                            if (newTag.replaceAll(" ", "") == "") {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: snackBarColor,
                                  content: GlobalText(
                                      localizeText:
                                          "content_edit_widget_empty_tag_error",
                                      textSize: 15.0),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              return;
                            } else if (newTag.length > 15) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: snackBarColor,
                                  content: GlobalText(
                                      localizeText:
                                          "content_edit_widget_more_than_15_error",
                                      textSize: 15.0),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              return;
                            }

                            setState(newTag);
                            tagNameController.clear();
                            Navigator.of(context).pop();
                          },
                          onChanged: (String value) {
                            setModalState(() {
                              selectedTagName = "";
                            });
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
    },
  );
}
