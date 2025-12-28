import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/bill_analysis.dart';

class BillAnalysisFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const BillAnalysisFormScreen({super.key, this.extra});

  @override
  ConsumerState<BillAnalysisFormScreen> createState() =>
      _BillAnalysisFormScreenState();
}

class _BillAnalysisFormScreenState
    extends ConsumerState<BillAnalysisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _periodStart;
  DateTime? _periodEnd;
  final _usageController = TextEditingController();
  final _amountController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photoPath = widget.extra?['photoPath'];
  }

  @override
  void dispose() {
    _usageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStart,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _periodStart ?? DateTime.now() : _periodEnd ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _periodStart = picked;
        } else {
          _periodEnd = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_periodStart == null || _periodEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select period dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createBillAnalysis(
        periodStart: _periodStart!,
        periodEnd: _periodEnd!,
        usage: double.parse(_usageController.text),
        amount: double.parse(_amountController.text),
        photoPath: _photoPath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill saved successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_photoPath != null) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppTheme.card,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_photoPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Period Start',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _periodStart != null
                      ? DateFormat('yyyy-MM-dd').format(_periodStart!)
                      : '',
                ),
                onTap: () => _selectDate(context, true),
                validator: (value) =>
                    _periodStart == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Period End',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _periodEnd != null
                      ? DateFormat('yyyy-MM-dd').format(_periodEnd!)
                      : '',
                ),
                onTap: () => _selectDate(context, false),
                validator: (value) => _periodEnd == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usageController,
                decoration: const InputDecoration(
                  labelText: 'Usage (gallons)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


