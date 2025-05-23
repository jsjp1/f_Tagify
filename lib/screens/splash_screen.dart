import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/utils/util.dart';

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
      duration: const Duration(seconds: 4),
    )..repeat();

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveTagsToAppGroup(List<String> tagNames) async {
    const platform = MethodChannel("com.ellipsoid.tagi/share");

    try {
      await platform.invokeMethod("saveTags", {"tags": tagNames});
    } on PlatformException catch (e) {
      debugPrint("Error occur: $e");
    }
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
      ]);

      // TODO: tag별 contents는 이후 tag detail screen 들어가면 채워지도록?
      await Future.wait(provider.tags
          .map((tag) => provider.pvFetchUserTagContents(tag.id, tag.tagName)));

      await _saveTagsToAppGroup(
          provider.tags.map((tag) => tag.tagName).toList());

      await checkSharedItems(context);

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
    List colorList;
    if (widget.loginResponse["is_premium"] == null) {
      colorList = basicColors;
    } else {
      colorList =
          widget.loginResponse["is_premium"] ? premiumColors : basicColors;
    }

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
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colorList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final color = entry.value;

                      final t = _controller.value * 4 * math.pi;
                      final fadeValue =
                          (0.5 + 0.5 * math.sin(t + index)).clamp(0.5, 1.0);

                      return Container(
                        width: 15,
                        height: 15,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          color: color.withOpacity(fadeValue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
