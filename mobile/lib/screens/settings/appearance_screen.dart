import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      if (provider.themeMode == ThemeMode.light) {
        _themeMode = 'light';
      } else if (provider.themeMode == ThemeMode.dark) {
        _themeMode = 'dark';
      } else {
        _themeMode = 'system';
      }
    });
  }

  void _setThemeMode(String mode) {
    Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Theme',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 24),
            RadioListTile<String>(
              value: 'system',
              groupValue: _themeMode,
              title: const Text('Device Default'),
              onChanged: (value) => _setThemeMode(value!),
            ),
            RadioListTile<String>(
              value: 'light',
              groupValue: _themeMode,
              title: const Text('Light Mode'),
              onChanged: (value) => _setThemeMode(value!),
            ),
            RadioListTile<String>(
              value: 'dark',
              groupValue: _themeMode,
              title: const Text('Dark Mode'),
              onChanged: (value) => _setThemeMode(value!),
            ),
          ],
        ),
      ),
    );
  }
}
