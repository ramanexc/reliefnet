import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reliefnet/themes/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reliefnet/l10n/app_translations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _checkBiometrics(ThemeProvider provider) async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Biometrics not supported on this device")),
          );
        }
        provider.setBiometric(false);
        return;
      }

      if (!provider.isBiometricEnabled) {
        // Try to authenticate to enable
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          biometricOnly: true,
        );
        if (didAuthenticate) {
          provider.setBiometric(true);
        }
      } else {
        provider.setBiometric(false);
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate(context, 'settings')),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: AppTranslations.translate(context, 'language')),
          Card(
            child: ListTile(
              title: Text(AppTranslations.translate(context, 'language')),
              trailing: DropdownButton<String>(
                value: themeProvider.locale.languageCode,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: 'en', child: Text("English")),
                  const DropdownMenuItem(value: 'hi', child: Text("हिंदी (Hindi)")),
                  const DropdownMenuItem(value: 'pa', child: Text("ਪੰਜਾਬੀ (Punjabi)")),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    themeProvider.setLocale(Locale(newValue));
                  }
                },
              ),
              leading: Icon(Icons.language, color: colorScheme.primary),
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'appearance')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppTranslations.translate(context, 'dark_mode')),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: colorScheme.primary,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'security')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppTranslations.translate(context, 'biometric')),
                  subtitle: const Text("Use fingerprint or face ID"),
                  secondary: Icon(Icons.fingerprint, color: colorScheme.primary),
                  value: themeProvider.isBiometricEnabled,
                  onChanged: (bool value) => _checkBiometrics(themeProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(AppTranslations.translate(context, 'app_lock')),
                  subtitle: Text(themeProvider.isAppLockEnabled ? "PIN is set" : "Protect your app with a PIN"),
                  leading: Icon(Icons.lock_outline, color: colorScheme.primary),
                  trailing: Switch(
                    value: themeProvider.isAppLockEnabled,
                    onChanged: (value) async {
                      if (value) {
                        final pin = await _showPinDialog();
                        if (pin != null && pin.length == 4) {
                          themeProvider.setAppPin(pin);
                          themeProvider.setAppLock(true);
                        }
                      } else {
                        themeProvider.setAppLock(false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'permissions')),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(AppTranslations.translate(context, 'camera')),
                  leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openAppSettings(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(AppTranslations.translate(context, 'location')),
                  leading: Icon(Icons.location_on_outlined, color: colorScheme.primary),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openAppSettings(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'colors')),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  ListTile(
                    title: Text(AppTranslations.translate(context, 'primary_color')),
                    subtitle: const Text("Choose the main theme color"),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _ColorOption(
                          color: const Color(0xFF6366F1),
                          isSelected: themeProvider.primaryColor.value == 0xFF6366F1,
                          onTap: () => themeProvider.setPrimaryColor(const Color(0xFF6366F1)),
                        ),
                        _ColorOption(
                          color: Colors.red,
                          isSelected: themeProvider.primaryColor.value == Colors.red.value,
                          onTap: () => themeProvider.setPrimaryColor(Colors.red),
                        ),
                        _ColorOption(
                          color: Colors.green,
                          isSelected: themeProvider.primaryColor.value == Colors.green.value,
                          onTap: () => themeProvider.setPrimaryColor(Colors.green),
                        ),
                        _ColorOption(
                          color: Colors.orange,
                          isSelected: themeProvider.primaryColor.value == Colors.orange.value,
                          onTap: () => themeProvider.setPrimaryColor(Colors.orange),
                        ),
                        _ColorOption(
                          color: Colors.pink,
                          isSelected: themeProvider.primaryColor.value == Colors.pink.value,
                          onTap: () => themeProvider.setPrimaryColor(Colors.pink),
                        ),
                        _ColorOption(
                          color: Colors.teal,
                          isSelected: themeProvider.primaryColor.value == Colors.teal.value,
                          onTap: () => themeProvider.setPrimaryColor(Colors.teal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'typography')),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(AppTranslations.translate(context, 'font_style')),
                  trailing: DropdownButton<String>(
                    value: themeProvider.fontFamily,
                    underline: const SizedBox(),
                    items: ['Poppins', 'Roboto', 'Open Sans', 'Lato', 'Montserrat']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) themeProvider.setFontFamily(newValue);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(AppTranslations.translate(context, 'font_size')),
                  subtitle: Slider(
                    value: themeProvider.fontSizeMultiplier,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: themeProvider.fontSizeMultiplier.toString(),
                    onChanged: (double value) => themeProvider.setFontSize(value),
                  ),
                  trailing: Text("${(themeProvider.fontSizeMultiplier * 100).toInt()}%"),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          _SectionHeader(title: AppTranslations.translate(context, 'ui_components')),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(AppTranslations.translate(context, 'button_roundness')),
                  subtitle: Slider(
                    value: themeProvider.buttonBorderRadius,
                    min: 0,
                    max: 30,
                    divisions: 6,
                    label: themeProvider.buttonBorderRadius.toInt().toString(),
                    onChanged: (double value) => themeProvider.setButtonShape(value),
                  ),
                  trailing: Container(
                    width: 40, height: 25,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(themeProvider.buttonBorderRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<String?> _showPinDialog() async {
    String pin = "";
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set App PIN"),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Enter 4-digit PIN"),
          onChanged: (value) => pin = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, pin), child: const Text("Save")),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 18,
          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      ),
    );
  }
}
