import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual status from backend
    final status = 'normal'; // 'normal', 'warning', 'confirmed'

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hi John 👋',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Here's how things look right now.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _buildStatusCard(context, status),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/upload'),
                  child: const Text('Upload or Scan'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String status) {
    String title;
    String body;
    Color cardColor;

    switch (status) {
      case 'warning':
        title = 'Something might need attention';
        body = 'Water use looks unusual.';
        cardColor = AppTheme.warning;
        break;
      case 'confirmed':
        title = 'Leak detected';
        body = "We'll help you take care of this.";
        cardColor = AppTheme.danger;
        break;
      default:
        title = 'Everything looks okay';
        body = "We're quietly watching your water use.";
        cardColor = AppTheme.success;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                status == 'confirmed'
                    ? Icons.warning
                    : status == 'warning'
                        ? Icons.info_outline
                        : Icons.check_circle_outline,
                color: cardColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

