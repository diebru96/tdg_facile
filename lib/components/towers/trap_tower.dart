import 'dart:ui';

import '../../models/tower_type.dart';
import 'base_tower.dart';

/// Explosive proximity trap – deals heavy area damage when triggered.
class TrapTower extends BaseTower {
  TrapTower() : super(data: towerDataFor(TowerType.trap));

  bool _triggered = false;
  double _explosionTimer = 0;

  @override
  bool performAttack() {
    if (_triggered) return false;

    final targets = enemiesInRange();
    if (targets.isEmpty) return false;

    _triggered = true;
    _explosionTimer = 0.4;

    for (final e in game.activeEnemies) {
      if ((e.worldCenter - worldCenter).length < data.areaRadius) {
        e.takeDamage(data.damage);
      }
    }
    // Destroy self after explosion
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isMounted) game.grid.removeTowerAt(gridCol, gridRow);
    });
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_explosionTimer > 0) _explosionTimer -= dt;
  }

  @override
  void drawTower(Canvas canvas) {
    if (_explosionTimer > 0) {
      // Draw explosion flash
      final r = data.areaRadius * (_explosionTimer / 0.4);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), r, Paint()..color = const Color(0xCCFF6600));
    }
    super.drawTower(canvas);
  }
}
