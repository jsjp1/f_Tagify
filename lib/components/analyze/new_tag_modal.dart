import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagify/global.dart';

Future<dynamic> setTagBottomModal(
    BuildContext context, Function(String) setState) {
  return showModalBottomSheet(
    backgroundColor: whiteBackgroundColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      TextEditingController tagNameController = TextEditingController();

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
                padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 0.0),
                child: GlobalText(
                  localizeText: "content_edit_widget_save_tag_name",
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
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      autocorrect: false,
                      autofocus: true,
                      cursorColor: mainColor,
                      controller: tagNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: mainColor, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: mainColor, width: 2.0),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(CupertinoIcons.clear_circled_solid),
                          onPressed: () {
                            tagNameController.clear();
                          },
                        ),
                      ),
                      onSubmitted: (String newTag) {
                        setState(newTag);
                        tagNameController.clear();
                        Navigator.of(context).pop();
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
}
