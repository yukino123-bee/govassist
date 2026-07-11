import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'language_selection_screen.dart';
import 'app_settings_screen.dart';
import 'legal_screens.dart';
import '../../core/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/service_data.dart';
import '../../core/translations.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _refreshProfile() async {
    final res = await ServiceData.fetchProfile();
    if (res['success'] == true) {
      final user = res['user'];
      UserSession().setUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', json.encode(user));
      if (mounted) {
        setState(() {});
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Failed to refresh profile'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings'.tr()),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Account Settings'.tr()),
                  _buildCardGroup([
                    _buildProfileMenu(
                      context,
                      'Edit Profile'.tr(),
                      'Update your personal details'.tr(),
                      Icons.person_outline,
                      Theme.of(context).primaryColor,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())).then((_) => setState(() {})),
                    ),
                    _buildProfileMenu(
                      context,
                      'Language'.tr(),
                      'Change app display language'.tr(),
                      Icons.language,
                      Colors.orange,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen())),
                    ),
                    _buildProfileMenu(
                      context,
                      'App Settings'.tr(),
                      'Notifications & display options'.tr(),
                      Icons.settings_outlined,
                      Colors.purple,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen())),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Legal'.tr()),
                  _buildCardGroup([
                    _buildProfileMenu(
                      context,
                      'Terms & Conditions'.tr(),
                      'Read our terms of service'.tr(),
                      Icons.description_outlined,
                      Colors.grey.shade700,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
                    ),
                    _buildProfileMenu(
                      context,
                      'Privacy Policy'.tr(),
                      'Data usage and protection'.tr(),
                      Icons.privacy_tip_outlined,
                      Colors.grey.shade700,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: Text(
                        'Log Out'.tr(),
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    final user = UserSession().currentUser;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
              ],
            ),
              child: ClipOval(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Builder(builder: (context) {
                    final profilePic = user?['profile_picture'];
                    if (profilePic == null) {
                      return const Icon(Icons.person, size: 50, color: Colors.grey);
                    }
                    final url = profilePic.toString().startsWith('http')
                        ? profilePic.toString()
                        : '${ServiceData.baseUrl.replaceAll('/api', '')}/$profilePic';
                        
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 50, color: Colors.grey);
                      },
                    );
                  }),
                ),
              ),
          ),
          const SizedBox(height: 16),
          Text(
            user?['full_name'] ?? 'Guest User',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?['email'] ?? 'guest@example.com',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildProfileMenu(
      BuildContext context, String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Log Out?'.tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: Text('Cancel'.tr(), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Clear user session and shared preferences
                        await UserSession().clearSession();
                        
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Log Out'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
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
