import 'package:hive/hive.dart';

part 'bill_analysis.g.dart';

@HiveType(typeId: 0)
class BillAnalysis extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  DateTime periodStart;

  @HiveField(2)
  DateTime periodEnd;

  @HiveField(3)
  double usage;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String? photoPath;

  @HiveField(6)
  DateTime createdAt;

  BillAnalysis({
    this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.usage,
    required this.amount,
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'usage': usage,
      'amount': amount,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BillAnalysis.fromJson(Map<String, dynamic> json) {
    return BillAnalysis(
      id: json['id'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      usage: (json['usage'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      photoPath: json['photo_path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}


