import 'package:hive/hive.dart';

part 'leak_check_result.g.dart';

@HiveType(typeId: 1)
class LeakCheckResult extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  double readingA;

  @HiveField(2)
  double readingB;

  @HiveField(3)
  bool noWaterUsed;

  @HiveField(4)
  double delta;

  @HiveField(5)
  bool leakDetected;

  @HiveField(6)
  String confidence;

  @HiveField(7)
  String? photoPathA;

  @HiveField(8)
  String? photoPathB;

  @HiveField(9)
  int durationMinutes;

  @HiveField(10)
  DateTime createdAt;

  LeakCheckResult({
    this.id,
    required this.readingA,
    required this.readingB,
    required this.noWaterUsed,
    required this.delta,
    required this.leakDetected,
    required this.confidence,
    this.photoPathA,
    this.photoPathB,
    required this.durationMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reading_a': readingA,
      'reading_b': readingB,
      'no_water_used': noWaterUsed,
      'delta': delta,
      'leak_detected': leakDetected,
      'confidence': confidence,
      'photo_path_a': photoPathA,
      'photo_path_b': photoPathB,
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LeakCheckResult.fromJson(Map<String, dynamic> json) {
    return LeakCheckResult(
      id: json['id'],
      readingA: (json['reading_a'] as num).toDouble(),
      readingB: (json['reading_b'] as num).toDouble(),
      noWaterUsed: json['no_water_used'] as bool,
      delta: (json['delta'] as num).toDouble(),
      leakDetected: json['leak_detected'] as bool,
      confidence: json['confidence'] as String,
      photoPathA: json['photo_path_a'],
      photoPathB: json['photo_path_b'],
      durationMinutes: json['duration_minutes'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}


