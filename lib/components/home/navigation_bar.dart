import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/analyze_screen.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/screens/tag_screen.dart';

class TagifyNavigationBar extends StatelessWidget {
  const TagifyNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TagifyProvider provider = context.watch<TagifyProvider>();

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
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(CupertinoIcons.house_alt_fill),
                  onPressed: () {
                    if (ModalRoute.of(context)?.settings.name != "/home") {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              HomeScreen(
                                  loginResponse: provider.loginResponse!),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 60),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(CupertinoIcons.folder_fill),
                  onPressed: () {
                    if (ModalRoute.of(context)?.settings.name != "/tag") {
                      Navigator.push(
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
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 35,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
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
                      var curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation1.drive(tween);

                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
              shape: StadiumBorder(),
              backgroundColor: mainColor,
              child: Image.asset("assets/img/app_logo_white.png"),
            ),
          ),
        ),
      ],
    );
  }
}
