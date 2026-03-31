import '../../models/tower_type.dart';
import '../projectiles/slow_orb.dart';
import 'base_tower.dart';

/// Freeze tower – fires slow orbs that chill enemies in its range.
class SlowTower extends BaseTower {
  SlowTower() : super(data: towerDataFor(TowerType.slow));

  @override
  bool performAttack() {
    final target = nearestEnemyInRange();
    if (target == null) return false;

    game.add(SlowOrb(origin: worldCenter.clone(), target: target, damage: data.damage, slowDuration: 3.0));
    return true;
  }
}
