import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class Notice extends StatelessWidget {
  final double widgetWidth;
  final double widgetHeight;

  const Notice(
      {super.key, required this.widgetWidth, required this.widgetHeight});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: widgetWidth * (0.3),
                height: widgetHeight * (0.95),
                // child: Image.asset("assets/app_main_icons_1024_1024.png"),
                child: Center(
                    child: GlobalText(
                  localizeText: "📢",
                  textSize: 40.0,
                )),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          height: widgetHeight * (0.35),
                          child: GlobalText(
                            localizeText: "This is Test Notice Title",
                            textSize: 17.0,
                            localization: false,
                            textColor: Colors.black,
                            isBold: true,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: widgetHeight * (0.5),
                          child: GlobalText(
                            localizeText:
                                "This is Test Notice body and nothing in here...",
                            textSize: 10.0,
                            localization: false,
                            overflow: TextOverflow.fade,
                            textColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
                // TODO: 공지 개수만큼 dot 생성
                ),
          ),
        ],
      ),
    );
  }
}

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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (0.11),
      child: Align(
        alignment: Alignment.topCenter,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: noticeWidgetColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            width: widgetWidth,
            height: widgetHeight,
            child: Notice(
                widgetWidth: widgetWidth,
                widgetHeight: widgetHeight), // TODO: 추후 DB 데이터로 채우기
          ),
        ),
      ),
    );
  }
}
