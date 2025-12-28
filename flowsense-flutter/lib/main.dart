import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'models/bill_analysis.dart';
import 'models/leak_check_result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters (generated files)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BillAnalysisAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(LeakCheckResultAdapter());
  }
  
  runApp(
    const ProviderScope(
      child: FlowSenseApp(),
    ),
  );
}

class FlowSenseApp extends StatelessWidget {
  const FlowSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlowSense',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

