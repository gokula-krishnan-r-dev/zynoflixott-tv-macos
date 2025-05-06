import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'ZynoFlix OTT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppTheme.primaryColor,
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          cardColor: AppTheme.cardColor,
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primaryColor,
            secondary: AppTheme.accentColor,
            surface: AppTheme.surfaceColor,
            background: AppTheme.backgroundColor,
            error: AppTheme.errorColor,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            titleMedium: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
          ),
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: AppTheme.primaryColor.withOpacity(0.3),
            labelTextStyle: MaterialStateProperty.resolveWith(
              (states) => const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: AppTheme.primaryColor,
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          cardColor: AppTheme.cardColor,
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primaryColor,
            secondary: AppTheme.accentColor,
            surface: AppTheme.surfaceColor,
            background: AppTheme.backgroundColor,
            error: AppTheme.errorColor,
          ),
        ),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
  }
}

class RotateDeviceScreen extends StatelessWidget {
  const RotateDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation,
              color: AppTheme.primaryColor,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Please rotate your device',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'This app works best in landscape mode',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
