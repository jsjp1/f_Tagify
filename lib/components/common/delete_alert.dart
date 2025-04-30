import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

Future<bool> showDeleteAlert(BuildContext context, String alertMessage) async {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  bool result = await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: GlobalText(
          localizeText: 'content_instance_really_delete_alert',
          textColor: isDarkMode ? whiteBackgroundColor : blackBackgroundColor,
          textSize: 20.0,
          isBold: true,
        ),
        content: GlobalText(
          localizeText: alertMessage,
          textSize: 15.0,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: GlobalText(
              localizeText: 'content_instance_really_delete_cancel',
              textSize: 15.0,
              textColor: Colors.grey,
              localization: true,
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
            child: GlobalText(
              localizeText: 'content_instance_really_delete_ok',
              textSize: 15.0,
              textColor: mainColor,
              localization: true,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      );
    },
  );

  return result;
}
