import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/utils/util.dart';

void exploreScreenUploadDialog(BuildContext context) {
  final double dialogWidth = MediaQuery.of(context).size.width * 0.8;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _UploadDialog(
        dialogWidth: dialogWidth,
        titleController: titleController,
        bodyController: bodyController,
      );
    },
  );
}

class _UploadDialog extends StatefulWidget {
  final double dialogWidth;
  final TextEditingController titleController;
  final TextEditingController bodyController;

  const _UploadDialog({
    required this.dialogWidth,
    required this.titleController,
    required this.bodyController,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  String selectedTagName = "";
  String encodedContentList = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: widget.dialogWidth,
        height: uploadDialogHeight,
        child: Container(
          decoration: BoxDecoration(
            color: whiteBackgroundColor,
            border: Border.all(color: Colors.grey, width: 2.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalText(
                  localizeText: "upload_dialog_title_controller_text",
                  textSize: 15.0,
                  isBold: true,
                ),
                TextField(
                    controller: widget.titleController, autocorrect: false),
                SizedBox(height: 20.0),
                GlobalText(
                  localizeText: "upload_dialog_body_controller_text",
                  textSize: 15.0,
                  isBold: true,
                ),
                TextField(
                    controller: widget.bodyController, autocorrect: false),
                SizedBox(height: 20.0),
                GlobalText(
                  localizeText: "upload_dialog_tags_text",
                  textSize: 15.0,
                  isBold: true,
                ),
                SizedBox(height: 10.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: provider.tags
                        .map(
                          (tag) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: TagContainer(
                              tag: tag,
                              isSelected: tag.tagName == selectedTagName,
                              onTap: () async {
                                setState(() {
                                  selectedTagName = tag.tagName;
                                });

                                provider.setTag(tag.tagName);
                                await provider.fetchContents();

                                Map<String, dynamic> contentListMap =
                                    contentListToMap(provider.contents);
                                encodedContentList =
                                    encodeTaggedContentsToBase64(
                                        contentListMap);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      if (encodedContentList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: snackBarColor,
                            content: GlobalText(
                              localizeText: "upload_dialog_no_tag_selected",
                              textSize: 15.0,
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }

                      await postArticle(
                        provider.loginResponse!["id"],
                        widget.titleController.text.isEmpty
                            ? "${provider.loginResponse!['username']}/ $selectedTagName"
                            : widget.titleController.text,
                        widget.bodyController.text,
                        encodedContentList,
                      );

                      await provider.fetchArticles();
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        width: 75.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: GlobalText(
                            localizeText: "upload_dialog_upload_button_text",
                            textSize: 15.0,
                            localization: true,
                            textColor: whiteBackgroundColor,
                            isBold: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TagContainer extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final GestureTapCallback onTap;

  const TagContainer({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: whiteBackgroundColor,
          border: Border.all(
            color: isSelected ? mainColor : contentInstanceTagBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: GlobalText(
            localizeText: tag.tagName,
            textSize: 15.0,
            textColor: tag.color,
            isBold: true,
            localization: false,
          ),
        ),
      ),
    );
  }
}
