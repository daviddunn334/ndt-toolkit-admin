import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    final authService = AuthService();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Company Logo
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    'assets/logos/logo_main_white.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                // Admin Panel Title
                Column(
                  children: [
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Integrity Specialists',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.85),
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  'Analytics',
                  Icons.analytics_outlined,
                  Icons.analytics,
                  0,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'News Management',
                  Icons.article_outlined,
                  Icons.article,
                  1,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'User Management',
                  Icons.people_outline,
                  Icons.people,
                  2,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Employee Management',
                  Icons.badge_outlined,
                  Icons.badge,
                  3,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Feedback Management',
                  Icons.feedback_outlined,
                  Icons.feedback,
                  4,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'PDF Management',
                  Icons.picture_as_pdf_outlined,
                  Icons.picture_as_pdf,
                  5,
                  isLargeScreen,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'CONTENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  'Create Post',
                  Icons.add_circle_outline,
                  Icons.add_circle,
                  6,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Drafts',
                  Icons.drafts_outlined,
                  Icons.drafts,
                  7,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Published',
                  Icons.public_outlined,
                  Icons.public,
                  8,
                  isLargeScreen,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accessoryAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData outlinedIcon,
    IconData filledIcon,
    int index,
    bool isLargeScreen, {
    VoidCallback? onTap,
  }) {
    final isSelected = index == selectedIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: isSelected
            ? AppTheme.primaryAccent.withOpacity(0.15)
            : Colors.transparent,
        border: isSelected
            ? Border.all(
                color: AppTheme.primaryAccent.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? filledIcon : outlinedIcon,
          color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryAccent : AppTheme.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        onTap: onTap ??
            () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(index);
            },
      ),
    );
  }
}
