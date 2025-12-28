import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import '../models/bill_analysis.dart';
import '../models/leak_check_result.dart';
import '../services/api_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<BillAnalysis> _bills = [];
  List<LeakCheckResult> _leakChecks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final bills = await apiService.getBillAnalyses();
      final leakChecks = await apiService.getLeakChecks();

      setState(() {
        _bills = bills;
        _leakChecks = leakChecks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  Future<void> _deleteBill(BillAnalysis bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _bills.remove(bill);
      });
      bill.delete();
    }
  }

  Future<void> _deleteLeakCheck(LeakCheckResult result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leak Check'),
        content: const Text('Are you sure you want to delete this leak check?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _leakChecks.remove(result);
      });
      result.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allItems = <_HistoryItem>[];
    allItems.addAll(_bills.map((b) => _HistoryItem(
          type: _HistoryItemType.bill,
          bill: b,
          date: b.createdAt,
        )));
    allItems.addAll(_leakChecks.map((l) => _HistoryItem(
          type: _HistoryItemType.leakCheck,
          leakCheck: l,
          date: l.createdAt,
        )));
    allItems.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: SafeArea(
        child: allItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'No history yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Icon(
                        item.type == _HistoryItemType.bill
                            ? Icons.receipt
                            : Icons.water_drop,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        item.type == _HistoryItemType.bill
                            ? 'Bill Analysis'
                            : 'Leak Check',
                      ),
                      subtitle: Text(
                        DateFormat('MMM d, y • h:mm a').format(item.date),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          if (item.type == _HistoryItemType.bill && item.bill != null) {
                            _deleteBill(item.bill!);
                          } else if (item.leakCheck != null) {
                            _deleteLeakCheck(item.leakCheck!);
                          }
                        },
                      ),
                      onTap: () {
                        // Show details
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              item.type == _HistoryItemType.bill
                                  ? 'Bill Details'
                                  : 'Leak Check Details',
                            ),
                            content: SingleChildScrollView(
                              child: item.type == _HistoryItemType.bill && item.bill != null
                                  ? _buildBillDetails(item.bill!)
                                  : item.leakCheck != null
                                      ? _buildLeakCheckDetails(item.leakCheck!)
                                      : const Text('No details'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBillDetails(BillAnalysis bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Period: ${DateFormat('MMM d').format(bill.periodStart)} - ${DateFormat('MMM d, y').format(bill.periodEnd)}'),
        const SizedBox(height: 8),
        Text('Usage: ${bill.usage.toStringAsFixed(2)} gallons'),
        const SizedBox(height: 8),
        Text('Amount: \$${bill.amount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildLeakCheckDetails(LeakCheckResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reading A: ${result.readingA.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        Text('Reading B: ${result.readingB.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        Text('Delta: ${result.delta.toStringAsFixed(2)} gallons'),
        const SizedBox(height: 8),
        Text('Leak Detected: ${result.leakDetected ? "Yes" : "No"}'),
        const SizedBox(height: 8),
        Text('Confidence: ${result.confidence}'),
      ],
    );
  }
}

enum _HistoryItemType { bill, leakCheck }

class _HistoryItem {
  final _HistoryItemType type;
  final BillAnalysis? bill;
  final LeakCheckResult? leakCheck;
  final DateTime date;

  _HistoryItem({
    required this.type,
    this.bill,
    this.leakCheck,
    required this.date,
  });
}


