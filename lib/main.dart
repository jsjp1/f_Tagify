import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:tagify/api/auth.dart';
import 'package:tagify/screens/auth_screen.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/splash_screen.dart';

void main() async {
  bool haveToReLogin = false; // refresh token 만료된 경우 재로그인 필요

  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  await dotenv.load(fileName: "assets/.env");
  await EasyLocalization.ensureInitialized();

  // TODO: 시작전 refresh token 만료기한 검사 -> login?

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // 세로 모드 고정

  Map<String, dynamic>? loginResponse = await checkLoginStatus();
  debugPrint("main.dart: Get loginResponse: $loginResponse");

  if (loginResponse != null) {
    // refresh token 만료시 재로그인 필요
    haveToReLogin =
        await checkRefreshToken(loginResponse["refresh_token"]) ? false : true;
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale("en", ''),
        Locale("ko", ''),
        Locale("ja", '')
      ],
      path: "assets/translations",
      fallbackLocale: const Locale("en", ''),
      startLocale: null,
      useOnlyLangCode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => TagifyProvider()),
        ],
        child: App(
          initialRoute: loginResponse == null
              ? "/auth"
              : haveToReLogin
                  ? "/auth"
                  : "/splash",
          initialLoginResponse: loginResponse ?? {},
        ),
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

  const App({
    super.key,
    required this.initialRoute,
    required this.initialLoginResponse,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: initialRoute,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case "/splash":
            final loginResponse = settings.arguments as Map<String, dynamic>? ??
                initialLoginResponse;
            page = SplashScreen(loginResponse: loginResponse);
            break;
          case "/auth":
            page = const AuthScreen();
            break;
          default:
            page = const AuthScreen();
            break;
        }

        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }
}
