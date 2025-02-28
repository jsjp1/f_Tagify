import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/analyze_screen.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/screens/tag_screen.dart';

class TagifyNavigationBarAB extends StatelessWidget {
  const TagifyNavigationBarAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: navigationBarHeight,
          color: whiteBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavigationBarButton(
                icon: provider.currentPage == "home"
                    ? Icon(CupertinoIcons.house_alt_fill,
                        color: mainColor, size: 30.0)
                    : Icon(CupertinoIcons.house_alt,
                        color: Colors.grey, size: 30.0),
                buttonName: "home",
                onPressed: () async {
                  if (provider.currentPage != "home") {
                    provider.setCurrentPage("home");
                    await provider.setTag("all");

                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            HomeScreen(loginResponse: provider.loginResponse!),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              ),
              NavigationBarButton(
                icon: Icon(CupertinoIcons.search, size: 30.0),
                buttonName: "search",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AnalyzeScreen(loginResponse: provider.loginResponse!),
                      transitionDuration: Duration(milliseconds: 300),
                      reverseTransitionDuration: Duration(milliseconds: 300),
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
              NavigationBarButton(
                icon: Icon(CupertinoIcons.globe,
                    color: provider.currentPage == "explore"
                        ? mainColor
                        : Colors.grey,
                    size: 30.0),
                buttonName: "explore",
                onPressed: () {
                  if (provider.currentPage != "explore") {
                    provider.setCurrentPage("explore");
                  }
                },
              ),
              NavigationBarButton(
                icon: provider.currentPage == "tag"
                    ? Icon(
                        CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
                        color: mainColor,
                        size: 30.0)
                    : Icon(CupertinoIcons.rectangle_on_rectangle_angled,
                        color: Colors.grey, size: 30.0),
                buttonName: "tag",
                onPressed: () async {
                  if (provider.currentPage != "tag") {
                    provider.setCurrentPage("tag");

                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            TagScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
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
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: icon,
          ),
          SizedBox(height: 2),
          Text(buttonName),
        ],
      ),
    );
  }
}
