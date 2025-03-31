import 'package:flutter/cupertino.dart';

import 'package:tagify/global.dart';

Future<bool> showDeleteAlert(BuildContext context) async {
  bool result = await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: GlobalText(
          localizeText: 'content_instance_really_delete_alert',
          textSize: 20.0,
          isBold: true,
        ),
        content: GlobalText(
          localizeText: 'content_instance_really_delete_text',
          textSize: 15.0,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: GlobalText(
              localizeText: 'content_instance_really_delete_cancel',
              textSize: 15.0,
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
