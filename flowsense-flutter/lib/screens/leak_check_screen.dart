import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

class LeakCheckScreen extends ConsumerStatefulWidget {
  const LeakCheckScreen({super.key});

  @override
  ConsumerState<LeakCheckScreen> createState() => _LeakCheckScreenState();
}

class _LeakCheckScreenState extends ConsumerState<LeakCheckScreen> {
  int _currentStep = 0;
  bool _tapsOff = false;
  bool _appliancesPaused = false;
  bool _irrigationOff = false;
  bool _noWaterUsed = false;
  double? _readingA;
  double? _readingB;
  String? _photoPathA;
  String? _photoPathB;
  int _timerMinutes = 10;
  final _readingAController = TextEditingController();
  final _readingBController = TextEditingController();

  @override
  void dispose() {
    _readingAController.dispose();
    _readingBController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _timerMinutes = settings.demoMode ? 2 : 10;
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _takePhoto(bool isReadingA) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        if (isReadingA) {
          _photoPathA = image.path;
        } else {
          _photoPathB = image.path;
        }
      });
    }
  }

  Future<void> _completeTest() async {
    if (_readingA == null || _readingB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both readings')),
      );
      return;
    }

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.createLeakCheck(
        readingA: _readingA!,
        readingB: _readingB!,
        noWaterUsed: _noWaterUsed,
        durationMinutes: _timerMinutes,
        photoPathA: _photoPathA,
        photoPathB: _photoPathB,
      );

      if (mounted) {
        context.push('/leak-check-result', extra: result.toJson());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep > 0)
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: AppTheme.background,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _currentStep == 4 ? _completeTest : _nextStep : null,
                      child: Text(_currentStep == 4 ? 'Complete' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _tapsOff && _appliancesPaused && _irrigationOff && _noWaterUsed;
      case 1:
        return _readingA != null;
      case 2:
        return true; // Timer is set
      case 3:
        return _readingB != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildPrepStep(context);
      case 1:
        return _buildReadingAStep(context);
      case 2:
        return _buildTimerStep(context);
      case 3:
        return _buildReadingBStep(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPrepStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's check together.",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        _buildCheckbox('Taps off', _tapsOff, (v) => setState(() => _tapsOff = v)),
        const SizedBox(height: 16),
        _buildCheckbox('Appliances paused', _appliancesPaused,
            (v) => setState(() => _appliancesPaused = v)),
        const SizedBox(height: 16),
        _buildCheckbox('Irrigation off', _irrigationOff,
            (v) => setState(() => _irrigationOff = v)),
        const SizedBox(height: 24),
        _buildCheckbox('No water used during test', _noWaterUsed,
            (v) => setState(() => _noWaterUsed = v)),
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      child: CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildReadingAStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading A',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        if (_photoPathA != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.card,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(File(_photoPathA!), fit: BoxFit.cover),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => _takePhoto(true),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Photo'),
        ),
        const SizedBox(height: 16),
        const Text('OR'),
        const SizedBox(height: 16),
        TextField(
          controller: _readingAController,
          decoration: const InputDecoration(
            labelText: 'Enter Reading Manually',
            hintText: '0.00',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _readingA = double.tryParse(value);
            });
          },
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.warning.withOpacity(0.1),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('OCR not enabled yet. Please enter the reading manually.'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wait Time',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '$_timerMinutes minutes',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _timerMinutes.toDouble(),
                  min: 2,
                  max: 30,
                  divisions: 28,
                  label: '$_timerMinutes minutes',
                  onChanged: (value) {
                    setState(() => _timerMinutes = value.toInt());
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Please wait for the specified time before taking Reading B.'),
      ],
    );
  }

  Widget _buildReadingBStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading B',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        if (_photoPathB != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.card,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(File(_photoPathB!), fit: BoxFit.cover),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => _takePhoto(false),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Photo'),
        ),
        const SizedBox(height: 16),
        const Text('OR'),
        const SizedBox(height: 16),
        TextField(
          controller: _readingBController,
          decoration: const InputDecoration(
            labelText: 'Enter Reading Manually',
            hintText: '0.00',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _readingB = double.tryParse(value);
            });
          },
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.warning.withOpacity(0.1),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('OCR not enabled yet. Please enter the reading manually.'),
          ),
        ),
      ],
    );
  }
}


