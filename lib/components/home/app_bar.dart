import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/auth.dart';
import 'package:tagify/global.dart';

class TagifyAppBar extends StatelessWidget {
  final String profileImage;

  const TagifyAppBar({super.key, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      color: whiteBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/app_main_icons_1024_1024.png",
                height: 40.0,
              ),
              GlobalText(
                localizeText: "Tagify",
                textSize: 25.0,
                isBold: true,
                textColor: Colors.black,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // TODO: 프로필 클릭 이벤트 추가
              showProfileMenu(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (profileImage != "")
                      ? NetworkImage(profileImage)
                      : AssetImage("assets/img/default_profile.png")
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showProfileMenu(BuildContext context) {
    showMenu(
      color: whiteBackgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: profileButtonContainerColor),
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      position: RelativeRect.fromLTRB(100, 115, 20, 0),
      items: [
        PopupMenuItem(
          height: 50,
          child: SizedBox(
            width: 100,
            child: ListTile(
              hoverColor: Colors.transparent,
              leading: const Icon(CupertinoIcons.settings_solid),
              title: GlobalText(
                localizeText: "profile_button_settings",
                textSize: 15.0,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/settings");
              },
            ),
          ),
        ),
        PopupMenuItem(
          height: 50,
          child: SizedBox(
            width: 100,
            child: ListTile(
              hoverColor: Colors.transparent,
              leading: const Icon(CupertinoIcons.arrow_right),
              title: GlobalText(
                localizeText: "profile_button_logout",
                textSize: 15.0,
              ),
              onTap: () async {
                Navigator.pop(context);
                await logout(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
