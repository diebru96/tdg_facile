import '../../models/tower_type.dart';
import '../enemies/base_enemy.dart';
import '../projectiles/bullet.dart';
import 'base_tower.dart';

/// Long-range, high-damage sniper tower – picks the furthest enemy in range.
class SniperTower extends BaseTower {
  SniperTower() : super(data: towerDataFor(TowerType.sniper));

  @override
  bool performAttack() {
    // Target the enemy that is furthest along (highest Y = closest to house)
    BaseEnemy? best;
    double bestY = double.negativeInfinity;

    for (final enemy in game.activeEnemies) {
      final d = (enemy.worldCenter - worldCenter).length;
      if (d < rangePixels && enemy.worldCenter.y > bestY) {
        bestY = enemy.worldCenter.y;
        best = enemy;
      }
    }

    if (best == null) return false;

    game.add(Bullet(origin: worldCenter.clone(), target: best, damage: data.damage, speed: 600, color: 0xFFFFFF00, radius: 4));
    return true;
  }
}
