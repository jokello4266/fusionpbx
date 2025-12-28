// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAnalysisAdapter extends TypeAdapter<BillAnalysis> {
  @override
  final int typeId = 0;

  @override
  BillAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillAnalysis(
      id: fields[0] as String?,
      periodStart: fields[1] as DateTime,
      periodEnd: fields[2] as DateTime,
      usage: fields[3] as double,
      amount: fields[4] as double,
      photoPath: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BillAnalysis obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.periodStart)
      ..writeByte(2)
      ..write(obj.periodEnd)
      ..writeByte(3)
      ..write(obj.usage)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

