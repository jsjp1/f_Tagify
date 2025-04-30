import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

Future<String?> showReasonModal(BuildContext context) async {
  TextEditingController controller = TextEditingController();

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlobalText(
              localizeText: "delete_reason_modal_title_text",
              textSize: 16.0,
              isBold: true,
            ),
            SizedBox(height: 12),
            TextField(
              cursorColor: mainColor,
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: tr("delete_reason_modal_hint_text"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: mainColor, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.all(12),
                    color: Colors.grey[300],
                    child: GlobalText(
                      localizeText: "delete_reason_modal_cancel",
                      textSize: 15.0,
                      textColor: blackBackgroundColor,
                      isBold: true,
                    ),
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.all(12),
                    color: mainColor,
                    child: GlobalText(
                      localizeText: "delete_reason_modal_ok",
                      textSize: 15.0,
                      textColor: whiteBackgroundColor,
                      isBold: true,
                    ),
                    onPressed: () {
                      Navigator.pop(context, controller.text.trim());
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
