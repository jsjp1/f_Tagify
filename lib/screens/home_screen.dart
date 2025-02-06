import 'package:flutter/material.dart';

import 'package:tagify/components/home/search_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/home/notice_widget.dart';
import 'package:tagify/components/home/navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  final dynamic loginResponse;

  const HomeScreen({super.key, required this.loginResponse});

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    debugPrint("current page: $currentRoute");
    debugPrint("loginResponse: $loginResponse");

    return Scaffold(
      backgroundColor: noticeWidgetColor,
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                print("Profile Icon Clicked!");
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: (loginResponse != null &&
                            loginResponse["existed_user_profile"]
                                    ["profile_image"] !=
                                null &&
                            loginResponse["existed_user_profile"]
                                    ["profile_image"]
                                .isNotEmpty)
                        ? NetworkImage(loginResponse["existed_user_profile"]
                            ["profile_image"])
                        : AssetImage("assets/img/default_profile.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: whiteBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset("assets/app_main_icons_1024_1024.png", height: 50.0),
            GlobalText(
              localizeText: "Tagify",
              textSize: 25.0,
              isBold: true,
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
