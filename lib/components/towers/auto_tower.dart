import '../../models/tower_type.dart';
import '../projectiles/bullet.dart';
import 'base_tower.dart';

/// Short-range rapid-fire automatic turret.
class AutoTower extends BaseTower {
  AutoTower() : super(data: towerDataFor(TowerType.auto));

  @override
  bool performAttack() {
    final target = nearestEnemyInRange();
    if (target == null) return false;

    gameRef.add(Bullet(origin: worldCenter.clone(), target: target, damage: data.damage, speed: 400, color: 0xFFFF8C00, radius: 3));
    return true;
  }
}
