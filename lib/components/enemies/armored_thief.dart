import 'dart:ui';

import '../../models/enemy_type.dart';
import 'base_enemy.dart';

/// Armoured intruder – 50 % damage reduction from all sources.
class ArmoredThief extends BaseEnemy {
  ArmoredThief({required super.column}) : super(data: enemyDataMap[EnemyType.armored]!);

  @override
  void drawBody(Canvas canvas) {
    // Armour plate look
    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), Paint()..color = const Color(0xFF4A4A4A));
    // Lighter centre panel
    canvas.drawRect(Rect.fromLTWH(6, 6, size.x - 12, size.y - 12), Paint()..color = const Color(0xFF707070));
  }
}
