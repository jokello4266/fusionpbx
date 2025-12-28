import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            Card(
              child: SwitchListTile(
                title: const Text('Demo mode'),
                subtitle: const Text('Use 2-minute timer for leak checks'),
                value: settings.demoMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDemoMode(value);
                },
                activeColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Store photos locally'),
                subtitle: const Text('Keep photos on device only'),
                value: settings.storePhotosLocally,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setStorePhotosLocally(value);
                },
                activeColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Connection',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Base URL',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.apiBaseUrl,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This URL is read-only. Configure via environment variables.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                title: const Text('About'),
                subtitle: const Text('FlowSense v1.0.0'),
                trailing: const Icon(Icons.info_outline),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About FlowSense'),
                      content: const Text(
                        'FlowSense helps you monitor your water usage and detect leaks.\n\n'
                        'Version 1.0.0\n\n'
                        'For support, please contact your administrator.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


