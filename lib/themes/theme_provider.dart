import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadSettings();
  }

  // Appearance
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = const Color(0xFF6366F1);
  double _fontSizeMultiplier = 1.0;
  String _fontFamily = 'Poppins';
  double _buttonBorderRadius = 12.0;

  // Security
  bool _isBiometricEnabled = false;
  bool _isAppLockEnabled = false;
  String _appPin = "";

  // Localization
  Locale _locale = const Locale('en');

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get primaryColor => _primaryColor;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  String get fontFamily => _fontFamily;
  double get buttonBorderRadius => _buttonBorderRadius;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAppLockEnabled => _isAppLockEnabled;
  String get appPin => _appPin;
  Locale get locale => _locale;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Localization
    final langCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(langCode);

    // Security
    _isBiometricEnabled = prefs.getBool('biometric') ?? false;
    _isAppLockEnabled = prefs.getBool('app_lock') ?? false;
    _appPin = prefs.getString('app_pin') ?? "";
    
    // Appearance
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? 0xFF6366F1);
    _fontFamily = prefs.getString('fontFamily') ?? 'Poppins';
    _fontSizeMultiplier = prefs.getDouble('fontSize') ?? 1.0;
    _buttonBorderRadius = prefs.getDouble('btnRadius') ?? 12.0;
    
    notifyListeners();
  }

  // Setters
  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDarkMode);
    notifyListeners();
  }

  void setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  void setFontSize(double multiplier) async {
    _fontSizeMultiplier = multiplier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', multiplier);
    notifyListeners();
  }

  void setFontFamily(String font) async {
    _fontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
    notifyListeners();
  }

  void setButtonShape(double radius) async {
    _buttonBorderRadius = radius;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('btnRadius', radius);
    notifyListeners();
  }

  void setBiometric(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', enabled);
    notifyListeners();
  }

  void setAppLock(bool enabled) async {
    _isAppLockEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock', enabled);
    notifyListeners();
  }

  void setAppPin(String pin) async {
    _appPin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
    notifyListeners();
  }

  // Generate Theme Data
  ThemeData getThemeData(bool isDark) {
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: _primaryColor,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      textTheme: _getGoogleFont(isDark).apply(
        fontSizeFactor: _fontSizeMultiplier,
        bodyColor: isDark ? Colors.white : Colors.black87,
        displayColor: isDark ? Colors.white : Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
    );
  }

  TextTheme _getGoogleFont(bool isDark) {
    switch (_fontFamily) {
      case 'Roboto': return GoogleFonts.robotoTextTheme();
      case 'Open Sans': return GoogleFonts.openSansTextTheme();
      case 'Lato': return GoogleFonts.latoTextTheme();
      case 'Montserrat': return GoogleFonts.montserratTextTheme();
      default: return GoogleFonts.poppinsTextTheme();
    }
  }
}
