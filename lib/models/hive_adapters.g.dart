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

class SuitAdapter extends TypeAdapter<Suit> {
  @override
  final typeId = 8;

  @override
  Suit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Suit.clubs;
      case 1:
        return Suit.diamonds;
      case 2:
        return Suit.hearts;
      case 3:
        return Suit.spades;
      default:
        return Suit.clubs;
    }
  }

  @override
  void write(BinaryWriter writer, Suit obj) {
    switch (obj) {
      case Suit.clubs:
        writer.writeByte(0);
      case Suit.diamonds:
        writer.writeByte(1);
      case Suit.hearts:
        writer.writeByte(2);
      case Suit.spades:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SolitaireCardAdapter extends TypeAdapter<SolitaireCard> {
  @override
  final typeId = 9;

  @override
  SolitaireCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolitaireCard(
      suit: fields[0] as Suit,
      rank: (fields[1] as num).toInt(),
      faceUp: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SolitaireCard obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.suit)
      ..writeByte(1)
      ..write(obj.rank)
      ..writeByte(2)
      ..write(obj.faceUp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolitaireCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GamePersistenceSnapshotAdapter
    extends TypeAdapter<GamePersistenceSnapshot> {
  @override
  final typeId = 10;

  @override
  GamePersistenceSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamePersistenceSnapshot(
      drawingUnopenedCards: (fields[0] as List).cast<SolitaireCard>(),
      drawingOpenedCards: (fields[1] as List).cast<SolitaireCard>(),
      drawingRevealVersion: (fields[2] as num).toInt(),
      drawingRevealCardKey: fields[3] as String?,
      elapsedSeconds: (fields[4] as num).toInt(),
      moveCounter: (fields[5] as num).toInt(),
      score: (fields[6] as num).toInt(),
      mainCards: (fields[7] as List)
          .map((e) => (e as List).cast<SolitaireCard>())
          .toList(),
      finishedCards: (fields[8] as List)
          .map((e) => (e as List).cast<SolitaireCard>())
          .toList(),
      mainRevealVersions: (fields[9] as List).cast<int>(),
      mainRevealCardKeys: (fields[10] as List).cast<String?>(),
      initialDrawingUnopenedCards: (fields[11] as List).cast<SolitaireCard>(),
      initialMainCards: (fields[12] as List)
          .map((e) => (e as List).cast<SolitaireCard>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, GamePersistenceSnapshot obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.drawingUnopenedCards)
      ..writeByte(1)
      ..write(obj.drawingOpenedCards)
      ..writeByte(2)
      ..write(obj.drawingRevealVersion)
      ..writeByte(3)
      ..write(obj.drawingRevealCardKey)
      ..writeByte(4)
      ..write(obj.elapsedSeconds)
      ..writeByte(5)
      ..write(obj.moveCounter)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.mainCards)
      ..writeByte(8)
      ..write(obj.finishedCards)
      ..writeByte(9)
      ..write(obj.mainRevealVersions)
      ..writeByte(10)
      ..write(obj.mainRevealCardKeys)
      ..writeByte(11)
      ..write(obj.initialDrawingUnopenedCards)
      ..writeByte(12)
      ..write(obj.initialMainCards);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePersistenceSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
