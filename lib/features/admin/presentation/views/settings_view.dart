import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _autoPurge = true;
  double _retentionDays = 30.0;
  bool _politePool = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink900.withAlpha(8),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Environment',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Settings & lab SSO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Manage internal laboratory authentication, data retention rules, and crawler limits.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    fontFamily: 'Manrope',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // SSO Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.green100),
                        ),
                        child: const Icon(Icons.check_rounded, color: AppColors.green700, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lab single sign-on active',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Authenticated with FPT Lab Keycloak provider (OAuth2 / OIDC)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Privacy Settings
                const Text(
                  'Manuscript privacy & retention',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Manrope', color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Author manuscripts are temporary evaluation drafts and are never added to the persistent corpus.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enforce automatic draft purge', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                  subtitle: Text('Purge temporary files after ${_retentionDays.toInt()} days (maximum: 30 days)', style: const TextStyle(fontSize: 12, fontFamily: 'Manrope')),
                  value: _autoPurge,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _autoPurge = val),
                ),
                Slider(
                  value: _retentionDays,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: AppColors.primary,
                  onChanged: _autoPurge ? (val) => setState(() => _retentionDays = val) : null,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Crawler Settings
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable CrossRef polite pool', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                  subtitle: const Text('Attaches lab email header to prevent HTTP 429 rate limit errors', style: TextStyle(fontSize: 12, fontFamily: 'Manrope')),
                  value: _politePool,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _politePool = val),
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
