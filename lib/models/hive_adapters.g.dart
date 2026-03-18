// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class SolitaireSettingsAdapter extends TypeAdapter<SolitaireSettings> {
  @override
  final typeId = 0;

  @override
  SolitaireSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolitaireSettings(
      drawCardPosition: fields[0] as DrawCardsPosition,
      drawCardsNumber: fields[1] as DrawCardsNumber,
      animationSpeed: fields[2] as AnimationSpeed,
      soundVolume: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, SolitaireSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.drawCardPosition)
      ..writeByte(1)
      ..write(obj.drawCardsNumber)
      ..writeByte(2)
      ..write(obj.animationSpeed)
      ..writeByte(3)
      ..write(obj.soundVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolitaireSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrawCardsPositionAdapter extends TypeAdapter<DrawCardsPosition> {
  @override
  final typeId = 1;

  @override
  DrawCardsPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DrawCardsPosition.left;
      case 1:
        return DrawCardsPosition.right;
      default:
        return DrawCardsPosition.left;
    }
  }

  @override
  void write(BinaryWriter writer, DrawCardsPosition obj) {
    switch (obj) {
      case DrawCardsPosition.left:
        writer.writeByte(0);
      case DrawCardsPosition.right:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawCardsPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrawCardsNumberAdapter extends TypeAdapter<DrawCardsNumber> {
  @override
  final typeId = 2;

  @override
  DrawCardsNumber read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DrawCardsNumber.one;
      case 1:
        return DrawCardsNumber.three;
      default:
        return DrawCardsNumber.one;
    }
  }

  @override
  void write(BinaryWriter writer, DrawCardsNumber obj) {
    switch (obj) {
      case DrawCardsNumber.one:
        writer.writeByte(0);
      case DrawCardsNumber.three:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawCardsNumberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimationSpeedAdapter extends TypeAdapter<AnimationSpeed> {
  @override
  final typeId = 3;

  @override
  AnimationSpeed read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return AnimationSpeed.normal;
      case 2:
        return AnimationSpeed.fast;
      default:
        return AnimationSpeed.normal;
    }
  }

  @override
  void write(BinaryWriter writer, AnimationSpeed obj) {
    switch (obj) {
      case AnimationSpeed.normal:
        writer.writeByte(1);
      case AnimationSpeed.fast:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationSpeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SolitaireThemeAdapter extends TypeAdapter<SolitaireTheme> {
  @override
  final typeId = 4;

  @override
  SolitaireTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolitaireTheme(
      tableTheme: fields[0] as TableTheme,
      cardBackTheme: fields[1] as CardBackTheme,
      cardFrontTheme: fields[2] as CardFrontTheme,
    );
  }

  @override
  void write(BinaryWriter writer, SolitaireTheme obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tableTheme)
      ..writeByte(1)
      ..write(obj.cardBackTheme)
      ..writeByte(2)
      ..write(obj.cardFrontTheme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolitaireThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TableThemeAdapter extends TypeAdapter<TableTheme> {
  @override
  final typeId = 5;

  @override
  TableTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TableTheme.green;
      case 1:
        return TableTheme.blue;
      default:
        return TableTheme.green;
    }
  }

  @override
  void write(BinaryWriter writer, TableTheme obj) {
    switch (obj) {
      case TableTheme.green:
        writer.writeByte(0);
      case TableTheme.blue:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardBackThemeAdapter extends TypeAdapter<CardBackTheme> {
  @override
  final typeId = 6;

  @override
  CardBackTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardBackTheme.blue;
      case 1:
        return CardBackTheme.red;
      default:
        return CardBackTheme.blue;
    }
  }

  @override
  void write(BinaryWriter writer, CardBackTheme obj) {
    switch (obj) {
      case CardBackTheme.blue:
        writer.writeByte(0);
      case CardBackTheme.red:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardBackThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardFrontThemeAdapter extends TypeAdapter<CardFrontTheme> {
  @override
  final typeId = 7;

  @override
  CardFrontTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardFrontTheme.classic;
      case 1:
        return CardFrontTheme.modern;
      default:
        return CardFrontTheme.classic;
    }
  }

  @override
  void write(BinaryWriter writer, CardFrontTheme obj) {
    switch (obj) {
      case CardFrontTheme.classic:
        writer.writeByte(0);
      case CardFrontTheme.modern:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardFrontThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
