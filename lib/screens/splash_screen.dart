import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tagify/global.dart';

import 'package:tagify/provider.dart';
import 'package:tagify/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic> loginResponse;

  const SplashScreen({super.key, required this.loginResponse});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    try {
      await provider.setInitialSetting(widget.loginResponse);
      await Future.wait([
        provider.pvFetchUserAllContents(),
        provider.pvFetchUserBookmarkedContents(),
        provider.pvFetchUserTags(),
        provider.pvFetchArticlesLimited(),
      ]);
      // TODO: tag별 contents는 이후 tag detail screen 들어가면 채워지도록
      await Future.wait(provider.tags
          .map((tag) => provider.pvFetchUserTagContents(tag.id, tag.tagName)));

      provider.version = version;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
              loginResponse: provider.loginResponse!,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
              loginResponse: provider.loginResponse!,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_animation.value),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Hero(
                    tag: "tagifyAppIcon",
                    child: Image.asset(
                      "assets/img/tagify_app_main_icon_3d_transparent.png",
                      scale: 5,
                    ),
                  ),
                  GlobalText(
                    localizeText: "splash_screen_waiting",
                    textSize: 20.0,
                    isBold: true,
                    localization: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
