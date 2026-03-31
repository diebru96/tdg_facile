import 'dart:ui';

import '../../models/enemy_type.dart';
import 'base_enemy.dart';

/// Fast but fragile thief – high speed, low HP.
class FastThief extends BaseEnemy {
  FastThief({required super.column}) : super(data: enemyDataMap[EnemyType.fast]!);

  @override
  void drawBody(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), Paint()..color = const Color(0xFFFFA500));
  }
}
