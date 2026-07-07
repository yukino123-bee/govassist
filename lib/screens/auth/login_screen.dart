import 'package:flutter/material.dart';
import '../../widgets/custom_widgets.dart';
import '../../core/theme.dart';
import '../main_layout.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import '../../data/service_data.dart';
import '../../core/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import '../../core/app_settings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await ServiceData.login(email, password);
    
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        UserSession().setUser(result['user']);
        
        // Cache user for biometric login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_user', json.encode(result['user']));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        if (result['unverified'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please verify your email to login.'.tr())),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(email: email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Login failed'.tr())),
          );
        }
      }
    }
  }

  Future<void> _biometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserString = prefs.getString('cached_user');
    
    if (cachedUserString == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No saved user found. Please login with password first.'.tr())),
        );
      }
      return;
    }

    try {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Biometric authentication not supported on this device.'.tr())),
          );
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login'.tr(),
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate && mounted) {
        final cachedUser = json.decode(cachedUserString);
        UserSession().setUser(cachedUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/logo.png', width: 50, height: 50),
              ),
              const SizedBox(height: 16),
              Text(
                'GovAssist',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access your services'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                controller: _emailController,
                label: 'Email'.tr(),
                hint: 'Enter your email address'.tr(),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password'.tr(),
                hint: 'Enter your password'.tr(),
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text('Forgot Password?'.tr()),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: 'Login'.tr(),
                      onPressed: _login,
                    ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: AppSettings.biometricLogin,
                builder: (context, useBiometric, _) {
                  if (useBiometric) {
                    return IconButton(
                      icon: const Icon(Icons.fingerprint, size: 48, color: AppTheme.primaryColor),
                      onPressed: _biometricAuth,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text('Register'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
