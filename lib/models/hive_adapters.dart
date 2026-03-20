import 'package:hive_ce/hive.dart';

import 'cards/solitaire_card.dart';
import 'cards/suit.dart';
import 'game/game_persistence_snapshot.dart';
import 'settings/animation_speed.dart';
import 'settings/draw_cards_number.dart';
import 'settings/draw_cards_position.dart';
import 'settings/solitaire_settings.dart';
import 'theme/card_back_theme.dart';
import 'theme/card_front_theme.dart';
import 'theme/solitaire_theme.dart';
import 'theme/table_theme.dart';

@GenerateAdapters([
  AdapterSpec<SolitaireSettings>(),
  AdapterSpec<DrawCardsPosition>(),
  AdapterSpec<DrawCardsNumber>(),
  AdapterSpec<AnimationSpeed>(),
  AdapterSpec<SolitaireTheme>(),
  AdapterSpec<TableTheme>(),
  AdapterSpec<CardBackTheme>(),
  AdapterSpec<CardFrontTheme>(),
  AdapterSpec<Suit>(),
  AdapterSpec<SolitaireCard>(),
  AdapterSpec<GamePersistenceSnapshot>(),
])
part 'hive_adapters.g.dart';
