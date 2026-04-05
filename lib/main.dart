import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reliefnet/pages/dashboard_page.dart';
import 'package:reliefnet/pages/home_page.dart';
import 'package:reliefnet/pages/report_page.dart';
import 'package:reliefnet/pages/volunteer_page.dart';
import 'package:reliefnet/themes/theme_light.dart';
import 'package:reliefnet/themes/theme_dark.dart';
import 'package:reliefnet/themes/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
      theme: lightmode,
      darkTheme: darkmode,
      themeMode: themeProvider.themeMode,
      // maybe of help later
      routes: {
        '/report': (context) => ReportPage(),
        '/dashboard': (context) => DashboardPage(),
        '/volunteer': (context) => VolunteerPage(),
      },
    );
  }
}
