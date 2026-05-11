import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String kPrivacyPolicyUrl =
    'https://lee-minki.github.io/Calibration-Calculator-Flutter/privacy.html';
const String kSupportEmail = 'minki.lee622@gmail.com';

Future<void> showAppAboutDialog(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  if (!context.mounted) return;

  showAboutDialog(
    context: context,
    applicationName: 'Calibration Calculator',
    applicationVersion: 'v${info.version} (build ${info.buildNumber})',
    applicationIcon: const Icon(
      Icons.bolt,
      size: 36,
      color: Color(0xFF00D4FF),
    ),
    applicationLegalese: '© 2025 lee-minki',
    children: [
      const SizedBox(height: 12),
      const Text(
        'Professional instrumentation calibration tools for field engineers.',
      ),
      const SizedBox(height: 16),
      _LinkRow(
        icon: Icons.privacy_tip_outlined,
        label: 'Privacy Policy',
        url: kPrivacyPolicyUrl,
      ),
      _LinkRow(
        icon: Icons.mail_outline,
        label: 'Contact: $kSupportEmail',
        url: 'mailto:$kSupportEmail?subject=Calibration%20Calculator',
      ),
    ],
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.url});

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF00D4FF)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF00D4FF)),
              ),
            ),
            const Icon(Icons.open_in_new, size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
