import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/user.dart';
import 'package:tagify/screens/premium_upgrade_screen.dart';
import 'package:tagify/utils/util.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Locale currentLocale = context.locale;

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final TextEditingController usernameController =
        TextEditingController(text: provider.loginResponse!["username"]);

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        title: GlobalText(
          localizeText: "settings_screen_title",
          textSize: 20.0,
          isBold: true,
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Stack(
            children: [
              Column(
                children: [
                  // 유저 프로필 정보
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: SizedBox(
                        // TODO: 프로필 이미지 변경 가능하도록 -> url이 아니라 image도 수용가능하도록
                        width: settingsScreenProfileImageHeight,
                        height: settingsScreenProfileImageHeight,
                        child: provider.loginResponse!["profile_image"] != ""
                            ? ClipOval(
                                child: Image(
                                  image: CachedNetworkImageProvider(
                                      provider.loginResponse!["profile_image"]),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                CupertinoIcons.person_crop_circle_fill,
                                size: settingsScreenProfileImageHeight,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  // 이름 수정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<TagifyProvider>(
                        builder: (context, value, child) {
                          return IntrinsicWidth(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 100.0,
                              ),
                              child: Center(
                                child: isEditing
                                    ? TextField(
                                        cursorColor: Colors.grey,
                                        controller: usernameController,
                                        autocorrect: false,
                                        autofocus: true,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: "YoutubeFont",
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        onSubmitted: (String text) async {
                                          setState(() {
                                            isEditing = false;
                                          });

                                          final ApiResponse<int> response =
                                              await updateUserName(
                                                  provider.loginResponse!["id"],
                                                  text,
                                                  provider.loginResponse![
                                                      "access_token"]);

                                          if (response.success) {
                                            // loginResponse 변경 및 sharedpreferences에서도 변경해주기 << 재접속시 필요
                                            provider.changeUserInfo(
                                                "username", text);

                                            String loginResponseString =
                                                jsonEncode(
                                                    provider.loginResponse!);

                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setString(
                                                "loginResponse",
                                                loginResponseString);
                                          }
                                        },
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          setState(() {
                                            isEditing = false;
                                          });
                                        },
                                      )
                                    : GlobalText(
                                        localizeText:
                                            provider.loginResponse!["username"],
                                        textSize: 15.0,
                                        isBold: true,
                                        overflow: TextOverflow.fade,
                                        localization: false,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 5.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        child: Icon(Icons.edit, size: 15.0, color: Colors.grey),
                      )
                    ],
                  ),
                  // 기타 설정
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 50.0),
                          GestureDetector(
                            onTap: () {
                              themeProvider.toggleTheme();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  isDarkMode ? Icons.sunny : Icons.dark_mode,
                                  size: 20.0,
                                  color: isDarkMode
                                      ? Colors.yellow
                                      : Colors.lightBlue,
                                ),
                                const SizedBox(width: 5.0),
                                GlobalText(
                                    localizeText: "settings_screen_dark_mode",
                                    textSize: 15.0),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlobalText(
                                  localizeText:
                                      "settings_screen_change_language",
                                  textSize: 15.0),
                              const Expanded(child: SizedBox.shrink()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .setLocale(const Locale("en")); // 영어

                                      setState(() {
                                        currentLocale = Locale("en");
                                      });
                                    },
                                    child: GlobalText(
                                      localizeText: "A",
                                      localization: false,
                                      isBold: currentLocale == Locale("en")
                                          ? true
                                          : false,
                                      textSize: 17.0,
                                    ),
                                  ),
                                  const SizedBox(width: 11.0),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .setLocale(const Locale("ko")); // 한국어

                                      setState(() {
                                        currentLocale = Locale("ko");
                                      });
                                    },
                                    child: GlobalText(
                                      localizeText: "가",
                                      localization: false,
                                      isBold: currentLocale == Locale("ko")
                                          ? true
                                          : false,
                                      textSize: 17.0,
                                    ),
                                  ),
                                  const SizedBox(width: 11.0),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .setLocale(const Locale("ja")); // 일본어

                                      setState(() {
                                        currentLocale = Locale("ja");
                                      });
                                    },
                                    child: GlobalText(
                                      localizeText: "あ",
                                      localization: false,
                                      isBold: currentLocale == Locale("ja")
                                          ? true
                                          : false,
                                      textSize: 17.0,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 30.0),
                          GestureDetector(
                            onTap: () {
                              launchContentUrl(tr("settings_screen_usage_url"));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.question_mark_outlined,
                                    size: 20.0, color: mainColor),
                                const SizedBox(width: 5.0),
                                GlobalText(
                                    localizeText: "settings_screen_usage",
                                    textSize: 15.0),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const SizedBox(height: 30.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 20.0,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 5.0),
                              GlobalText(
                                  localizeText:
                                      "settings_screen_current_version",
                                  textSize: 15.0),
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                provider.version,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30.0),
                          GestureDetector(
                            onTap: () {
                              launchContentUrl(
                                  tr("settings_screen_privacy_policy_url"));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.privacy_tip,
                                    size: 20.0, color: Colors.grey),
                                const SizedBox(width: 5.0),
                                GlobalText(
                                    localizeText:
                                        "settings_screen_privacy_policy",
                                    textSize: 15.0),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          GestureDetector(
                            onTap: () {
                              // TODO: 결제 창 띄우기
                              if (provider.loginResponse!["is_premium"]) {
                                // 이미 프리미엄 회원이라면, 아무 동작도 하지 않음
                              } else {
                                Navigator.push(context, CustomPageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return PremiumUpgradeScreen();
                                  },
                                ));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.workspace_premium_outlined,
                                    size: 20.0, color: Colors.orangeAccent),
                                const SizedBox(width: 5.0),
                                GlobalText(
                                    localizeText: provider
                                            .loginResponse!["is_premium"]
                                        ? "settings_screen_premium_upgrade_already"
                                        : "settings_screen_premium_upgrade",
                                    textSize: 14.0),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                ],
              ),

              // 로그아웃 및 회원탈퇴
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 10.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await logout(context);
                      },
                      child: GlobalText(
                        localizeText: "settings_screen_logout_text",
                        textSize: 12.0,
                        textColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    GestureDetector(
                      onTap: () async {
                        // TODO: 회원탈퇴
                        // await delete_account();
                      },
                      child: GlobalText(
                        localizeText: "settings_screen_leave_text",
                        textSize: 12.0,
                        textColor: Colors.red,
                        isBold: true,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
