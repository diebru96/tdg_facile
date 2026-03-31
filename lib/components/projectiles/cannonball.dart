import 'dart:ui';

import 'package:flame/components.dart';

import 'base_projectile.dart';

/// Slow-moving cannonball that detonates at a world position for splash damage.
class Cannonball extends BaseProjectile {
  final Vector2 targetPos;
  final double splashRadius;

  Cannonball({required super.origin, required this.targetPos, required super.damage, required this.splashRadius, super.speed = 200});

  @override
  bool moveAndCheckImpact(double dt) {
    final dir = (targetPos - position)..normalize();
    position += dir * speed * dt;
    return (targetPos - position).length < 8;
  }

  @override
  void onImpact() {
    // Deal damage to all enemies within splashRadius
    for (final enemy in game.activeEnemies) {
      if ((enemy.worldCenter - position).length <= splashRadius) {
        enemy.takeDamage(damage);
      }
    }
    // Visual explosion – add a temporary effect
    game.add(_ExplosionEffect(position: position.clone(), radius: splashRadius));
  }

  @override
  void drawProjectile(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 7, Paint()..color = const Color(0xFF333333));
    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFF666666));
  }
}

/// Short-lived explosion visual effect only.
class _ExplosionEffect extends PositionComponent {
  final double radius;
  double _timer = 0.4;

  _ExplosionEffect({required super.position, required this.radius}) : super(priority: 5);

  @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;
    if (_timer <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = 1 - (_timer / 0.4);
    final r = radius * progress;
    final alpha = (1 - progress);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Color.fromRGBO(255, 120, 0, alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }
}
