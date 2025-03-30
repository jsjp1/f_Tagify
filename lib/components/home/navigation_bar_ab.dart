import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/analyze_screen.dart';
import 'package:tagify/screens/explore_screen.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/screens/tag_screen.dart';

class TagifyNavigationBar extends StatelessWidget {
  const TagifyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Column(
      children: [
        Divider(
          height: 0.0,
          thickness: 0.5,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: navigationBarHeight,
              color: whiteBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<TagifyProvider>(
                    builder: (context, provider, child) {
                      return NavigationBarButton(
                        icon: provider.currentPage == "home"
                            ? Icon(CupertinoIcons.house_alt_fill,
                                color: mainColor, size: 30.0)
                            : Icon(CupertinoIcons.house_alt,
                                color: Colors.grey, size: 30.0),
                        buttonName: "navigation_bar_button_home",
                        onPressed: () async {
                          provider.currentPage = "home";
                          provider.currentTag = "all";

                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  HomeScreen(
                                      loginResponse: provider.loginResponse!),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  NavigationBarButton(
                    icon: Icon(CupertinoIcons.search,
                        color: Colors.grey, size: 30.0),
                    buttonName: "navigation_bar_button_search",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AnalyzeScreen(
                                  loginResponse: provider.loginResponse!),
                          transitionDuration: Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation1, animation2, child) {
                            var begin = Offset(0.0, 1.0);
                            var end = Offset.zero;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: Curves.easeInOut));
                            var offsetAnimation = animation1.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                  ),
                  Consumer<TagifyProvider>(
                    builder: (context, provider, child) {
                      return NavigationBarButton(
                        icon: provider.currentPage == "explore"
                            ? Icon(
                                CupertinoIcons.arrow_up_arrow_down_circle_fill,
                                color: mainColor,
                                size: 30.0,
                              )
                            : Icon(CupertinoIcons.arrow_up_arrow_down_circle,
                                color: Colors.grey, size: 30.0),
                        buttonName: "navigation_bar_button_explore",
                        onPressed: () async {
                          provider.currentPage = "explore";

                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  ExploreScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<TagifyProvider>(
                    builder: (context, provider, child) {
                      return NavigationBarButton(
                        icon: provider.currentPage == "tag"
                            ? Icon(
                                CupertinoIcons
                                    .rectangle_fill_on_rectangle_angled_fill,
                                color: mainColor,
                                size: 30.0)
                            : Icon(CupertinoIcons.rectangle_on_rectangle_angled,
                                color: Colors.grey, size: 30.0),
                        buttonName: "navigation_bar_button_tag",
                        onPressed: () async {
                          provider.currentPage = "tag";

                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  TagScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NavigationBarButton extends StatelessWidget {
  final Icon icon;
  final String buttonName;
  final VoidCallback onPressed;

  const NavigationBarButton(
      {super.key,
      required this.icon,
      required this.buttonName,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: navigationBarIconButtonHeight,
        height: navigationBarIconButtonHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 1.0),
            GlobalText(
              localizeText: buttonName,
              textSize: 13.0,
              localization: true,
              isBold: false,
              textColor: icon.color,
            ),
          ],
        ),
      ),
    );
  }
}
