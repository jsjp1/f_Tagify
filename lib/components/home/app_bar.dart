import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/animated_icon_widget.dart';

class TagifyAppBar extends StatelessWidget {
  String addText;
  Color appIconColor;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoImageTap;

  TagifyAppBar(
      {super.key,
      this.addText = "",
      this.appIconColor = mainColor,
      this.onProfileTap,
      this.onLogoImageTap});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      height: appBarHeight,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onLogoImageTap,
            child: Row(
              children: [
                provider.loginResponse!["is_premium"]
                    ? LuxInfiniteFlowIcon(
                        iconColor: appIconColor, iconWidth: logoImageHeight)
                    : Image.asset(
                        "assets/img/app_logo_white.png",
                        height: logoImageHeight,
                        color: appIconColor,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GlobalText(
                          localizeText: "Tagify$addText",
                          textSize: 25.0,
                          letterSpacing: -1.5,
                          isBold: true,
                          textColor: isDarkMode
                              ? whiteBackgroundColor
                              : blackBackgroundColor,
                          overflow: TextOverflow.visible,
                          localization: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expanded(child: Container(color: Colors.transparent)),
          GestureDetector(
            onTap: () {
              if (onProfileTap != null) {
                onProfileTap!();
              }
            },
            child: Container(
              width: profileImageHeight,
              height: profileImageHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: provider.loginResponse!["profile_image"] != ""
                  ? ClipOval(
                      child: Image(
                        image: CachedNetworkImageProvider(
                            provider.loginResponse!["profile_image"]),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(CupertinoIcons.person_crop_circle_fill,
                      size: profileImageHeight, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
