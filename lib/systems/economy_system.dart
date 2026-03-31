import 'package:flame/components.dart';

import '../game/home_defense_game.dart';
import '../models/level_data.dart';

/// Generates money at regular intervals and holds the money state.
///
/// Money notifications are forwarded via [HomeDefenseGame.addMoney].
class EconomySystem extends Component with HasGameReference<HomeDefenseGame> {
  double _timer = 0;
  late LevelData _level;

  EconomySystem({required HomeDefenseGame game});

  void reset(LevelData level) {
    _level = level;
    _timer = 0;
  }

  void addMoney(int amount) => game.addMoney(amount);

  @override
  void update(double dt) {
    super.update(dt);

    if (game.state.index != 1) return; // only tick while playing

    _timer += dt;
    if (_timer >= _level.moneyInterval) {
      _timer -= _level.moneyInterval;
      game.addMoney(_level.moneyAmount);
    }
  }
}
