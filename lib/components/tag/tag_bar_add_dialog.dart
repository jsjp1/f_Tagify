import 'package:flutter/material.dart';

import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/global.dart';

Future<void> showFixedTagDialog({
  required BuildContext context,
  required List<String> fixedTags,
  required List<String> allTags,
  required void Function(List<String> updatedTags) onTagsUpdated,
}) async {
  final Set<String> localFixedTags = {...fixedTags};

  await showDialog(
    context: context,
    builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shadowColor: darkContentInstanceBoxShadowColor,
          insetPadding: EdgeInsets.symmetric(horizontal: 10.0),
          backgroundColor:
              isDarkMode ? lightBlackBackgroundColor : whiteBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: GlobalText(
                    localizeText: "tag_bar_add_dialog_title_text",
                    letterSpacing: -1.0,
                    textSize: 20.0,
                    isBold: true,
                  ),
                ),
                const SizedBox(height: 25.0),
                allTags.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: GlobalText(
                            localizeText: "tag_bar_add_dialog_empty",
                            textSize: 14.0,
                            textColor: Colors.grey[700],
                            isBold: false,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: allTags.map((tagName) {
                          final isSelected = localFixedTags.contains(tagName);
                          return TagContainer(
                            tagColor: isDarkMode
                                ? darkContentInstanceTagTextColor
                                : contentInstanceTagTextColor,
                            tagName: tagName,
                            textSize: 13.0,
                            isSelected: isSelected,
                            isLastButton: !isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  localFixedTags.remove(tagName);
                                } else {
                                  localFixedTags.add(tagName);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: GlobalText(
                        localizeText: "tag_bar_add_dialog_cancel",
                        letterSpacing: -1.0,
                        textSize: 15.0,
                        textColor: isDarkMode
                            ? whiteBackgroundColor
                            : lightBlackBackgroundColor,
                        isBold: true,
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    ElevatedButton(
                      onPressed: () {
                        onTagsUpdated(localFixedTags.toList());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const GlobalText(
                        localizeText: "tag_bar_add_dialog_ok",
                        letterSpacing: -1.0,
                        textSize: 15.0,
                        textColor: whiteBackgroundColor,
                        isBold: true,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
    },
  );
}
