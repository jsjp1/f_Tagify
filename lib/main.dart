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

  final bool isLoggedIn = await checkLoginStatus();
  debugPrint("isLoggedIn: $isLoggedIn");

  runApp(
    EasyLocalization(
      supportedLocales: [Locale("en", ''), Locale("ko", '')],
      path: "assets/translations",
      fallbackLocale: Locale("en", ''),
      child: App(
        initialRoute: isLoggedIn ? '/home' : '/auth',
      ),
    ),
  );
}

Future<bool> checkLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isLoggedIn") ?? false;
}

class App extends StatelessWidget {
  final String initialRoute;

  const App({super.key, required this.initialRoute});

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
          final loginResponse = settings.arguments;
          return MaterialPageRoute(
            settings: RouteSettings(name: '/home'),
            builder: (context) => HomeScreen(loginResponse: loginResponse),
          );
        } else if (settings.name == '/auth') {
          return MaterialPageRoute(
              settings: RouteSettings(name: '/auth'),
              builder: (context) => AuthScreen());
        } else {
          // TODO
        }
        return null;
      },
    );
  }
}
