import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/tv_app_screen.dart';
import 'theme/app_theme.dart';
import 'utils/responsive_layout.dart';

void main() {
  // For TV apps, set preferred orientations to landscape
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Optional: Hide system overlays for immersive experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZynoFlix OTT TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.landscape
              ? const TVAppScreen()
              : const RotateDeviceScreen();
        },
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
