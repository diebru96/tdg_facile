import 'dart:math' as math;
import 'dart:ui';

import '../../models/enemy_type.dart';
import 'base_enemy.dart';

/// Ghost – ignores all physical towers, moves straight to the house.
class SpecialThief extends BaseEnemy {
  SpecialThief({required super.column}) : super(data: enemyDataMap[EnemyType.special]!);

  double _phaseTimer = 0;

  @override
  void update(double dt) {
    _phaseTimer += dt;
    super.update(dt);
  }

  @override
  void drawBody(Canvas canvas) {
    // Pulsing translucent ghost body
    final alpha = (0.5 + 0.25 * math.sin(_phaseTimer * 3)).clamp(0.25, 0.75);
    canvas.drawOval(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), Paint()..color = Color.fromRGBO(160, 0, 255, alpha));
  }
}
