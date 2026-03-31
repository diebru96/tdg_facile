import '../../models/tower_type.dart';
import '../projectiles/bullet.dart';
import 'base_tower.dart';

/// Fast-firing single-target projectile tower.
class GunTower extends BaseTower {
  GunTower() : super(data: towerDataFor(TowerType.gun));

  @override
  bool performAttack() {
    final target = nearestEnemyInRange();
    if (target == null) return false;

    game.add(Bullet(origin: worldCenter.clone(), target: target, damage: data.damage));
    return true;
  }
}
