import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/auth.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/settings_screen.dart';

class TagifyAppBar extends StatelessWidget {
  const TagifyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      height: appBarHeight,
      color: whiteBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/img/app_logo_white.png",
                height: logoImageHeight,
                color: mainColor,
                colorBlendMode: BlendMode.srcIn,
              ),
              GlobalText(
                localizeText: "Tagify",
                textSize: 25.0,
                isBold: true,
                textColor: Colors.black,
                overflow: TextOverflow.clip,
                localization: false,
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
                  image: provider.loginResponse!["profile_image"] != ""
                      ? CachedNetworkImageProvider(
                          provider.loginResponse!["profile_image"])
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
          child: ListTile(
            hoverColor: Colors.transparent,
            leading: const Icon(CupertinoIcons.settings_solid),
            title: SizedBox(
              width: 100.0,
              child: GlobalText(
                localizeText: "profile_button_settings",
                textSize: 15.0,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ),
        PopupMenuItem(
          height: 50,
          child: ListTile(
            hoverColor: Colors.transparent,
            leading: const Icon(CupertinoIcons.arrow_right),
            title: SizedBox(
              width: 100.0,
              child: GlobalText(
                localizeText: "profile_button_logout",
                textSize: 15.0,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await logout(context);
            },
          ),
        ),
      ],
    );
  }
}
