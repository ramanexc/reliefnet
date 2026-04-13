import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reliefnet/l10n/app_translations.dart';

import 'package:reliefnet/main-pages/apply_volunteer_page.dart';
import 'package:reliefnet/main-pages/dashboard_page.dart';
import 'package:reliefnet/main-pages/home_page.dart';
import 'package:reliefnet/main-pages/report_page.dart';
import 'package:reliefnet/main-pages/volunteer_page.dart';
import 'package:reliefnet/login-signup/login_page.dart';
import 'package:reliefnet/themes/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getThemeData(false),
      darkTheme: themeProvider.getThemeData(true),
      themeMode: themeProvider.themeMode,
      locale: themeProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('pa'),
      ],
      routes: {
        '/report': (context) => const ReportPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/volunteer': (context) => const VolunteerPage(),
        '/apply_volunteer': (context) => const ApplyVolunteerPage(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const SecurityWrapper(child: Homepage());
        }
        return const LoginPage();
      },
    );
  }
}

class SecurityWrapper extends StatefulWidget {
  final Widget child;
  const SecurityWrapper({super.key, required this.child});

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper> {
  bool _isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    // If no security enabled, just let them in
    if (!provider.isBiometricEnabled && !provider.isAppLockEnabled) {
      if (mounted) {
        setState(() => _isAuthenticated = true);
      }
      return;
    }

    // Try Biometrics first if enabled
    if (provider.isBiometricEnabled) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Authenticate to access ReliefNet',
          stickyAuth: true,
          useErrorDialogs: true,
        );
        if (didAuthenticate && mounted) {
          setState(() => _isAuthenticated = true);
          return;
        }
      } catch (e) {
        debugPrint("Biometric error: $e");
      }
    }

    // If Biometric fails or is not enabled, but PIN is enabled, stay on PIN screen
    if (!provider.isAppLockEnabled && !provider.isBiometricEnabled) {
       if (mounted) {
         setState(() => _isAuthenticated = true);
       }
    }
  }

  void _verifyPin(String enteredPin, String correctPin) {
    if (enteredPin == correctPin) {
      setState(() => _isAuthenticated = true);
    } else {
      setState(() {
        _errorMsg = "Incorrect PIN. Try again.";
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    if (_isAuthenticated) return widget.child;

    // PIN Screen UI
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              "Security Lock",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Enter your 4-digit PIN to continue"),
            const SizedBox(height: 40),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 20),
              decoration: InputDecoration(
                counterText: "",
                errorText: _errorMsg.isEmpty ? null : _errorMsg,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _verifyPin(value, provider.appPin);
                }
              },
            ),
            const SizedBox(height: 40),
            if (provider.isBiometricEnabled)
              TextButton.icon(
                onPressed: _checkSecurity,
                icon: const Icon(Icons.fingerprint),
                label: const Text("Use Biometrics"),
              ),
          ],
        ),
      ),
    );
  }
}
