import 'package:flutter/material.dart';
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

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
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

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              loginResponse: provider.loginResponse!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              loginResponse: provider.loginResponse!,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
