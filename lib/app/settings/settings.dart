import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import '../../core/models/size_config.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _pickDateAndGoToDashboard(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2023), // Adjust based on your launch date
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && context.mounted) {
      // Using push instead of go so the user can easily hit "back" to return to settings
      context.push('/settings/shop-dashboard', extra: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            title: Text('Settings'),
            floating: true,
            pinned: true,
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().cardPadd(25),
              vertical: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── ANALYTICS SECTION ──
                _SectionHeader(title: 'Analytics & Reports'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Daily Shop Dashboard',
                      subtitle: 'View revenue, trends, and top items by date',
                      iconColor: scheme.primary,
                      onTap: () => _pickDateAndGoToDashboard(context),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Staff Dashboard',
                      subtitle: 'Track shifts and revenue by team member',
                      iconColor: Colors.blue,
                      onTap: () => context.go('/settings/staff-dashboard'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── MANAGEMENT SECTION ──
                _SectionHeader(title: 'Management'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.people_alt_rounded,
                      title: 'Staff',
                      subtitle: 'Manage your team and roles',
                      iconColor: Colors.orange,
                      onTap: () => context.go('/settings/staff'),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsTile(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Menu',
                      subtitle: 'Edit items, categories, and pricing',
                      iconColor: Colors.green,
                      onTap: () => context.go('/settings/menu'),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsTile(
                      icon: Icons.fastfood_rounded,
                      title: 'Combo Menus',
                      subtitle: 'Create and manage combo meals',
                      iconColor: Colors.teal,
                      onTap: () => context.go('/settings/combo-menus'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── SYSTEM SECTION ──
                _SectionHeader(title: 'System'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      textColor: scheme.error,
                      iconColor: scheme.error,
                      hideChevron: true,
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40), // Extra scroll padding at bottom
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── UI Helper Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias, // Ensures ink splashes stay inside rounded corners
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.hideChevron = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool hideChevron;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeIconColor = iconColor ?? scheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeIconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: activeIconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!hideChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
}