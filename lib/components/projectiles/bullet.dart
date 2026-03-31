import 'dart:ui';


import 'base_projectile.dart';

/// Standard homing bullet – deals direct damage to a single target.
class Bullet extends HomingProjectile {
  final int color;
  final double radius;

  Bullet({required super.origin, required super.target, required super.damage, super.speed = 350, this.color = 0xFFFFFFFF, this.radius = 4});

  @override
  void onImpact() => target.takeDamage(damage);

  @override
  void drawProjectile(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, Paint()..color = Color(color));
    // Glow
    canvas.drawCircle(
      Offset.zero,
      radius + 2,
      Paint()
        ..color = Color(color).withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}
