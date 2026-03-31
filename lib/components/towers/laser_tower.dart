import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/tower_type.dart';
import 'base_tower.dart';

/// Rapid-fire laser beam tower – deals continuous damage to nearest enemy.
class LaserTower extends BaseTower {
  LaserTower() : super(data: towerDataFor(TowerType.laser));

  Vector2? _laserEnd;

  @override
  bool performAttack() {
    final target = nearestEnemyInRange();
    if (target == null) {
      _laserEnd = null;
      return false;
    }
    target.takeDamage(data.damage);
    _laserEnd = target.worldCenter.clone();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Fade laser line between shots
    if (_laserEnd != null && nearestEnemyInRange() == null) {
      _laserEnd = null;
    }
  }

  @override
  void drawTower(Canvas canvas) {
    super.drawTower(canvas);

    if (_laserEnd == null) return;

    // Draw laser beam in world space relative to grid parent
    final startLocal = worldCenter - game.grid!.absolutePosition;
    final endLocal = _laserEnd! - game.grid!.absolutePosition;
    final localStart = startLocal - position;
    final localEnd = endLocal - position;

    canvas.drawLine(
      Offset(localStart.x, localStart.y),
      Offset(localEnd.x, localEnd.y),
      Paint()
        ..color = const Color(0xFFFF2200)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
    );
  }
}
