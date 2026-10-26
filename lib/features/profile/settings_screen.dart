import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PageHeader('Setting'),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 30, 10, 24),
      children: [
        for (final item in [
          (
            'Account Information',
            'Change your account information',
            Icons.person,
          ),
          ('Password', 'Change your password', Icons.visibility),
          (
            'Payment Methods',
            'Add your credit / debit cards',
            Icons.account_balance_wallet,
          ),
          ('Invite Your Friends', 'Get \$3 for each invitation!', Icons.edit),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.$3, size: 23, color: AppColors.black),
              title: Text(
                item.$1,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  item.$2,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: () async {
                switch (item.$1) {
                  case 'Account Information':
                    go(context, '/edit-profile');
                  case 'Payment Methods':
                    go(context, '/wallet?return=true');
                  case 'Invite Your Friends':
                    await Clipboard.setData(
                      const ClipboardData(
                        text:
                            'Explore digital art with DiveSea · divesea://home',
                      ),
                    );
                    if (context.mounted) {
                      toast(
                        context,
                        'Invitation copied. Rewards are part of the UI preview.',
                      );
                    }
                  case 'Password':
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Demo account'),
                        content: const Text(
                          'This app does not store passwords. Connect an authentication service to enable password changes.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                }
              },
            ),
          ),
      ],
    ),
  );
}
