import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:tagify/screens/analyze_screen.dart';
import 'package:tagify/screens/auth_screen.dart';
import 'package:tagify/screens/content_detail_screen.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/screens/settings_screen.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/dio.dart';
import 'package:tagify/screens/tag_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // 세로 모드 고정
  ApiClient();

  Map<String, dynamic>? loginResponse = await checkLoginStatus();
  debugPrint("main.dart: Get loginResponse: $loginResponse");

  if (loginResponse != null) {
    await loadAuthToken(loginResponse["access_token"]);
  }

  runApp(
    EasyLocalization(
      supportedLocales: [Locale("en", ''), Locale("ko", '')],
      path: "assets/translations",
      fallbackLocale: Locale("en", ''),
      child: App(
        initialRoute: loginResponse == null ? '/auth' : '/home',
        initialLoginResponse: loginResponse ?? {},
      ),
    ),
  );
}

Future<Map<String, dynamic>?> checkLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  if (isLoggedIn) {
    String? loginResponseString = prefs.getString("loginResponse");
    return loginResponseString == null ? null : jsonDecode(loginResponseString);
  }
  return null;
}

class App extends StatelessWidget {
  final String initialRoute;
  final Map<String, dynamic> initialLoginResponse;

  const App(
      {super.key,
      required this.initialRoute,
      required this.initialLoginResponse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TagifyProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: initialRoute,
        routes: {
          "/home": (context) => HomeScreen(loginResponse: initialLoginResponse),
          "/analyze": (context) =>
              AnalyzeScreen(loginResponse: initialLoginResponse),
          "/tag": (context) => TagScreen(),
          "/auth": (context) => const AuthScreen(),
          "/settings": (context) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/home":
              final loginResponse = settings.arguments is Map<String, dynamic>
                  ? settings.arguments as Map<String, dynamic>
                  : initialLoginResponse;
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomeScreen(
                  loginResponse: loginResponse,
                ),
                transitionDuration: Duration(seconds: 0),
              );
            case "/auth":
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AuthScreen(),
                transitionDuration: Duration(seconds: 0),
              );
            default:
              return MaterialPageRoute(builder: (context) => AuthScreen());
          }
        },
      ),
    );
  }
}
