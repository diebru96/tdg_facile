import '../../models/tower_type.dart';
import '../projectiles/cannonball.dart';
import 'base_tower.dart';

/// Slow-firing area-damage artillery tower.
class CannonTower extends BaseTower {
  CannonTower() : super(data: towerDataFor(TowerType.cannon));

  @override
  bool performAttack() {
    final target = nearestEnemyInRange();
    if (target == null) return false;

    game.add(Cannonball(origin: worldCenter.clone(), targetPos: target.worldCenter.clone(), damage: data.damage, splashRadius: data.areaRadius));
    return true;
  }
}
