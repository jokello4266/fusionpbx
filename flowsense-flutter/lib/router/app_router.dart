import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/leak_check_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/find_plumber_screen.dart';
import '../screens/leak_check_result_screen.dart';
import '../screens/bill_analysis_form_screen.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/leak-check',
            builder: (context, state) => const LeakCheckScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/find-plumber',
        builder: (context, state) => const FindPlumberScreen(),
      ),
      GoRoute(
        path: '/leak-check-result',
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>?;
          return LeakCheckResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/bill-analysis-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BillAnalysisFormScreen(extra: extra);
        },
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: const Color(0xFF3BA6A6),
        unselectedItemColor: const Color(0xFF5F7373),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Leak Check',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/home') return 0;
    if (location == '/upload') return 1;
    if (location == '/leak-check') return 2;
    if (location == '/history') return 3;
    if (location == '/settings') return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/upload');
        break;
      case 2:
        context.go('/leak-check');
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}

