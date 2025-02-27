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
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      TextEditingController tagNameController = TextEditingController();
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GlobalText(
                  localizeText: "content_edit_widget_save_tag_name",
                  textSize: 22.0,
                  isBold: true,
                  localization: true,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
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
                            borderSide: BorderSide(color: mainColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: mainColor),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(CupertinoIcons.delete_left_fill),
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
                    const SizedBox(height: 150.0),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      );
    },
  );
}
