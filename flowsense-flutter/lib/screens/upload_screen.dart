import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import 'bill_analysis_form_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Show us what you received.',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              _buildOption(
                context,
                icon: Icons.camera_alt,
                title: 'Take a photo',
                onTap: () => _handlePhotoOption(context, ImageSource.camera),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                icon: Icons.upload_file,
                title: 'Upload a document',
                onTap: () => _handlePhotoOption(context, ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                icon: Icons.email,
                title: 'Forward an email',
                onTap: () => _showEmailInstructions(context),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                icon: Icons.edit,
                title: 'Enter numbers manually',
                onTap: () => _handleManualEntry(context),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "We only read what's needed.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePhotoOption(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null && context.mounted) {
      context.push(
        '/bill-analysis-form',
        extra: {'photoPath': image.path},
      );
    }
  }

  void _showEmailInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward Email'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email forwarding is coming soon.'),
            SizedBox(height: 16),
            Text('For now, please use one of the other options:'),
            SizedBox(height: 8),
            Text('• Take a photo'),
            Text('• Upload a document'),
            Text('• Enter numbers manually'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleManualEntry(BuildContext context) {
    context.push('/bill-analysis-form', extra: {});
  }
}

