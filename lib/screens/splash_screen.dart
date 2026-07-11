import 'package:flutter/material.dart';
import '../core/user_session.dart';
import 'auth/login_screen.dart';
import 'main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCacheAndNavigate();
  }

  Future<void> _checkCacheAndNavigate() async {
    // Wait for at least 1 second to show splash screen (optional, but good for UX)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final hasSession = await UserSession().loadSession();

    if (mounted) {
      if (hasSession) {
        // Cached session found, go straight to main app!
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        // No cached session, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'GovAssist',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
