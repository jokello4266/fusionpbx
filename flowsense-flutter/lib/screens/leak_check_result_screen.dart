import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LeakCheckResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;

  const LeakCheckResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No result data')),
      );
    }

    final leakDetected = result!['leak_detected'] as bool? ?? false;
    final confidence = result!['confidence'] as String? ?? 'Unknown';
    final delta = result!['delta'] as num? ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultHeader(context, leakDetected, confidence),
              const SizedBox(height: 32),
              if (leakDetected) ...[
                _buildReassurance(context),
                const SizedBox(height: 32),
                _buildNextSteps(context),
                const SizedBox(height: 32),
                _buildWhyWeThink(context, delta),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.push('/find-plumber'),
                  child: const Text('Find a Plumber'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Keep monitoring'),
                ),
              ] else ...[
                _buildNoLeakContent(context, confidence),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/leak-check'),
                  child: const Text('Repeat Test'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/upload'),
                  child: const Text('Upload Bill'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(
    BuildContext context,
    bool leakDetected,
    String confidence,
  ) {
    return Card(
      color: leakDetected ? AppTheme.danger.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              leakDetected ? Icons.warning : Icons.check_circle,
              size: 64,
              color: leakDetected ? AppTheme.danger : AppTheme.success,
            ),
            const SizedBox(height: 16),
            Text(
              leakDetected ? 'Leak detected' : 'No flow detected',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              leakDetected
                  ? "Water flowed during a time when no water was being used."
                  : "We didn't detect water movement during your test.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Confidence: $confidence',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReassurance(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You're not in trouble.",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              "We'll help you take care of this.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What should I do next?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            _buildStepItem('1. Turn off the main water supply if safe to do so'),
            _buildStepItem('2. Contact a licensed plumber for inspection'),
            _buildStepItem('3. Document the issue with photos if possible'),
            _buildStepItem('4. Monitor your water usage after repairs'),
            _buildStepItem('5. Keep records for insurance if needed'),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildWhyWeThink(BuildContext context, num delta) {
    return ExpansionTile(
      title: const Text('Why we think this'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Water meter reading changed by ${delta.toStringAsFixed(2)} gallons during the test period when no water should have been used. This indicates water flow, which suggests a leak.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildNoLeakContent(BuildContext context, String confidence) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Next Steps',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            const Text('If you continue to have concerns, you can:'),
            const SizedBox(height: 16),
            _buildStepItem('Repeat the leak check test'),
            _buildStepItem('Upload a recent water bill for analysis'),
            _buildStepItem('Monitor your usage over time'),
          ],
        ),
      ),
    );
  }
}

