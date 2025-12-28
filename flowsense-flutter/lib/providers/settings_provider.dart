import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool demoMode;
  final bool storePhotosLocally;
  final String apiBaseUrl;

  SettingsState({
    this.demoMode = false,
    this.storePhotosLocally = true,
    this.apiBaseUrl = 'http://143.198.227.148/api',
  });

  SettingsState copyWith({
    bool? demoMode,
    bool? storePhotosLocally,
    String? apiBaseUrl,
  }) {
    return SettingsState(
      demoMode: demoMode ?? this.demoMode,
      storePhotosLocally: storePhotosLocally ?? this.storePhotosLocally,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    state = SettingsState(
      demoMode: box.get('demo_mode', defaultValue: false),
      storePhotosLocally: box.get('store_photos_locally', defaultValue: true),
      apiBaseUrl: box.get('api_base_url', defaultValue: 'http://143.198.227.148/api'),
    );
  }

  Future<void> setDemoMode(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('demo_mode', value);
    state = state.copyWith(demoMode: value);
  }

  Future<void> setStorePhotosLocally(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('store_photos_locally', value);
    state = state.copyWith(storePhotosLocally: value);
  }

  Future<void> setApiBaseUrl(String value) async {
    final box = await Hive.openBox('settings');
    await box.put('api_base_url', value);
    state = state.copyWith(apiBaseUrl: value);
  }
}

