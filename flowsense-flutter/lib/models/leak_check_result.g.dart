// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_check_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeakCheckResultAdapter extends TypeAdapter<LeakCheckResult> {
  @override
  final int typeId = 1;

  @override
  LeakCheckResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeakCheckResult(
      id: fields[0] as String?,
      readingA: fields[1] as double,
      readingB: fields[2] as double,
      noWaterUsed: fields[3] as bool,
      delta: fields[4] as double,
      leakDetected: fields[5] as bool,
      confidence: fields[6] as String,
      photoPathA: fields[7] as String?,
      photoPathB: fields[8] as String?,
      durationMinutes: fields[9] as int,
      createdAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LeakCheckResult obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.readingA)
      ..writeByte(2)
      ..write(obj.readingB)
      ..writeByte(3)
      ..write(obj.noWaterUsed)
      ..writeByte(4)
      ..write(obj.delta)
      ..writeByte(5)
      ..write(obj.leakDetected)
      ..writeByte(6)
      ..write(obj.confidence)
      ..writeByte(7)
      ..write(obj.photoPathA)
      ..writeByte(8)
      ..write(obj.photoPathB)
      ..writeByte(9)
      ..write(obj.durationMinutes)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeakCheckResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

