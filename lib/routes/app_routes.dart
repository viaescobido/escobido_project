import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/report_form_screen.dart';

/// Named routes: "/" (Home), "/login" (Login), "/report" (Report Form).
class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const report = '/report';

  static Route<dynamic> generate(RouteSettings s) {
    final Widget page;
    switch (s.name) {
      case login:
        page = const LoginScreen();
        break;
      case report:
        page = const ReportFormScreen();
        break;
      default:
        page = const HomeScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}