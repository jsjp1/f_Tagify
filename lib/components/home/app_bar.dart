import 'package:flutter/material.dart';

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
}
