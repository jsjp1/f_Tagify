import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class NoticeWidget extends StatefulWidget {
  const NoticeWidget({super.key});

  @override
  NoticeWidgetState createState() => NoticeWidgetState();
}

class NoticeWidgetState extends State<NoticeWidget> {
  @override
  void initState() {
    super.initState();
    // TODO: 네트워크 요청을 통해 공지 받아오기 혹은 const
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.85);
    final double widgetHeight = MediaQuery.of(context).size.height * (0.09);

    return Container(
      color: whiteBackgroundColor,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * (0.11),
      child: Align(
        alignment: Alignment.topCenter,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: noticeWidgetColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: widgetWidth,
            height: widgetHeight,
          ),
        ),
      ),
    );
  }
}
