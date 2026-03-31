import 'dart:ui';

import 'package:flame/components.dart';

import '../../game/home_defense_game.dart';
import '../enemies/base_enemy.dart';

/// Abstract base for all projectiles fired by towers.
abstract class BaseProjectile extends PositionComponent with HasGameRef<HomeDefenseGame> {
  final int damage;
  final double speed;

  bool _hit = false;

  BaseProjectile({required Vector2 origin, required this.damage, required this.speed}) : super(position: origin.clone(), priority: 4);

  /// Move toward target each frame.  Return true when impact occurs.
  bool moveAndCheckImpact(double dt);

  @override
  void update(double dt) {
    super.update(dt);
    if (_hit) return;
    if (moveAndCheckImpact(dt)) {
      _hit = true;
      onImpact();
      removeFromParent();
    }

    // Remove if out of bounds
    final s = gameRef.size;
    if (position.x < -50 || position.x > s.x + 50 || position.y < -100 || position.y > s.y + 50) {
      removeFromParent();
    }
  }

  /// Called on impact.  Apply damage / effects here.
  void onImpact();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawProjectile(canvas);
  }

  void drawProjectile(Canvas canvas);
}

/// Homing projectile that tracks a specific [BaseEnemy].
abstract class HomingProjectile extends BaseProjectile {
  final BaseEnemy target;

  HomingProjectile({required super.origin, required this.target, required super.damage, required super.speed});

  @override
  bool moveAndCheckImpact(double dt) {
    if (target.isDead || !target.isMounted) {
      // Target gone – self-destruct
      removeFromParent();
      return false;
    }

    final dir = (target.worldCenter - position)..normalize();
    position += dir * speed * dt;

    return (target.worldCenter - position).length < 10;
  }
}
