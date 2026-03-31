import 'package:flame/components.dart';

import '../game/game_state.dart';
import '../game/home_defense_game.dart';
import '../models/level_data.dart';

/// Generates money at regular intervals based on the current [LevelData].
///
/// Call [reset] at the start of every level before gameplay begins.
class EconomySystem extends Component with HasGameReference<HomeDefenseGame> {
  double _timer = 0;
  LevelData? _level;

  /// Prepare this system for a new level. Must be called before [GameState.playing].
  void reset(LevelData level) {
    _level = level;
    _timer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only tick during active gameplay.
    if (game.state != GameState.playing) return;
    final level = _level;
    if (level == null) return;

    _timer += dt;
    if (_timer >= level.moneyInterval) {
      _timer -= level.moneyInterval;
      game.addMoney(level.moneyAmount);
    }
  }
}
