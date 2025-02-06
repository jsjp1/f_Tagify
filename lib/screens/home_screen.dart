import 'package:flutter/material.dart';

import 'package:tagify/components/search_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/notice_widget.dart';
import 'package:tagify/components/navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  final dynamic loginResponse;

  // TODO: 세션 관련 처리
  const HomeScreen({super.key, required this.loginResponse});

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    debugPrint("current page: $currentRoute");

    return Scaffold(
      backgroundColor: noticeWidgetColor,
      appBar: AppBar(
        backgroundColor: whiteBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset("assets/app_main_icons_1024_1024.png", height: 50.0),
            GlobalText(
              localizeText: "Tagify",
              textSize: 25.0,
              isBold: false,
              textColor: Colors.black,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            NoticeWidget(),
            SearchBarWidget(),
          ],
        ),
      ),
      bottomNavigationBar: TagifyNavigationBar(
        loginResponse: loginResponse,
      ),
    );
  }
}
