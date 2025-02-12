import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/screens/auth_screen.dart';
import 'package:tagify/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await EasyLocalization.ensureInitialized();

  Map<String, dynamic>? loginResponse = await checkLoginStatus();
  debugPrint("main.dart: Saved loginResponse: $loginResponse");

  runApp(
    EasyLocalization(
      supportedLocales: [Locale("en", ''), Locale("ko", '')],
      path: "assets/translations",
      fallbackLocale: Locale("en", ''),
      child: App(
        initialRoute: loginResponse == null ? '/auth' : '/home',
        initialLoginResponse:
            loginResponse == null ? {} : loginResponse["data"],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> checkLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  if (isLoggedIn) {
    String? loginResponseJson = prefs.getString("loginResponse");
    return loginResponseJson == null ? null : jsonDecode(loginResponseJson);
  }
  return null;
}

class App extends StatelessWidget {
  final String initialRoute;
  final Map<String, dynamic>? initialLoginResponse;

  const App(
      {super.key,
      required this.initialRoute,
      required this.initialLoginResponse});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final loginResponse = settings.arguments ?? initialLoginResponse;
          return MaterialPageRoute(
            settings: RouteSettings(name: '/home'),
            builder: (context) => HomeScreen(loginResponse: loginResponse),
          );
        } else if (settings.name == '/auth') {
          return MaterialPageRoute(
              settings: RouteSettings(name: '/auth'),
              builder: (context) => AuthScreen());
        } else {
          return null;
        }
      },
    );
  }
}
