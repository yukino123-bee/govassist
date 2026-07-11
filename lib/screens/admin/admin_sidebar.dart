import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final VoidCallback onSignOut;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          _buildLogo(),
          const Divider(height: 1, color: Colors.black12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isSelected: currentRoute == 'Dashboard',
                  onTap: () => onNavigate('Dashboard'),
                ),
                _SidebarItem(
                  icon: Icons.list_alt,
                  title: 'Services',
                  isSelected: currentRoute == 'Services',
                  onTap: () => onNavigate('Services'),
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  title: 'Requirements',
                  isSelected: currentRoute == 'Requirements',
                  onTap: () => onNavigate('Requirements'),
                ),
                _SidebarItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Eligibility',
                  isSelected: currentRoute == 'Eligibility',
                  onTap: () => onNavigate('Eligibility'),
                ),
                _SidebarItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Inquiries',
                  isSelected: currentRoute == 'Inquiries',
                  onTap: () => onNavigate('Inquiries'),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  title: 'Users',
                  isSelected: currentRoute == 'Users',
                  onTap: () => onNavigate('Users'),
                ),
                _SidebarItem(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Assessments',
                  isSelected: currentRoute == 'Assessments',
                  onTap: () => onNavigate('Assessments'),
                ),
                _SidebarItem(
                  icon: Icons.folder_open,
                  title: 'Documents',
                  isSelected: currentRoute == 'Documents',
                  onTap: () => onNavigate('Documents'),
                ),
                _SidebarItem(
                  icon: Icons.file_copy_outlined,
                  title: 'Document Templates',
                  isSelected: currentRoute == 'Document Templates',
                  onTap: () => onNavigate('Document Templates'),
                ),
                _SidebarItem(
                  icon: Icons.campaign,
                  title: 'Announcements',
                  isSelected: currentRoute == 'Announcements',
                  onTap: () => onNavigate('Announcements'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          _SidebarItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isSelected: false,
            onTap: onSignOut,
            textColor: AppTheme.primaryColor,
            iconColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 28, height: 28),
          const SizedBox(width: 12),
          Text(
            'GovAssist',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppTheme.primaryColor
        : (textColor ?? Colors.grey.shade700);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : (iconColor ?? Colors.grey.shade500),
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
