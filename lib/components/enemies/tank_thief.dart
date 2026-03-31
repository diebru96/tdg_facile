import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/enemy_type.dart';
import 'base_enemy.dart';

/// Slow but tanky bully – high HP, deals heavy house damage.
class TankThief extends BaseEnemy {
  TankThief({required super.column}) : super(data: enemyDataMap[EnemyType.tank]!, enemySize: Vector2(38, 38));

  @override
  void drawBody(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(2, 2, size.x - 4, size.y - 4), Paint()..color = const Color(0xFF8B0000));
  }
}
