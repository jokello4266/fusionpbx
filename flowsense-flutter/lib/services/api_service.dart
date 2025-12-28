import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill_analysis.dart';
import '../models/leak_check_result.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://143.198.227.148/api',
  );
  return ApiService(baseUrl: baseUrl);
});

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required String baseUrl})
      : baseUrl = baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _dio.get('/health');
    return response.data;
  }

  Future<LeakCheckResult> createLeakCheck({
    required double readingA,
    required double readingB,
    required bool noWaterUsed,
    int durationMinutes = 10,
    String? photoPathA,
    String? photoPathB,
  }) async {
    final response = await _dio.post(
      '/leak-checks',
      data: {
        'reading_a': readingA,
        'reading_b': readingB,
        'no_water_used': noWaterUsed,
        'duration_minutes': durationMinutes,
        'photo_path_a': photoPathA,
        'photo_path_b': photoPathB,
      },
    );
    return LeakCheckResult.fromJson(response.data);
  }

  Future<List<LeakCheckResult>> getLeakChecks({int limit = 50}) async {
    final response = await _dio.get(
      '/leak-checks',
      queryParameters: {'limit': limit},
    );
    return (response.data as List)
        .map((json) => LeakCheckResult.fromJson(json))
        .toList();
  }

  Future<BillAnalysis> createBillAnalysis({
    required DateTime periodStart,
    required DateTime periodEnd,
    required double usage,
    required double amount,
    String? photoPath,
  }) async {
    final response = await _dio.post(
      '/bill-analyses',
      data: {
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'usage': usage,
        'amount': amount,
        'photo_path': photoPath,
      },
    );
    return BillAnalysis.fromJson(response.data);
  }

  Future<List<BillAnalysis>> getBillAnalyses({int limit = 50}) async {
    final response = await _dio.get(
      '/bill-analyses',
      queryParameters: {'limit': limit},
    );
    return (response.data as List)
        .map((json) => BillAnalysis.fromJson(json))
        .toList();
  }

  Future<List<Map<String, dynamic>>> findPlumbers({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get(
      '/plumbers',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}

