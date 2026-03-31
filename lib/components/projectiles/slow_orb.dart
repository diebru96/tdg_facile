import 'dart:ui';

import '../enemies/base_enemy.dart';
import 'base_projectile.dart';

/// Slow orb that chills an enemy on impact – deals minor damage and applies slow.
class SlowOrb extends HomingProjectile {
  final double slowDuration;

  SlowOrb({required super.origin, required super.target, required super.damage, required this.slowDuration, super.speed = 250});

  @override
  void onImpact() {
    target.takeDamage(damage);
    target.applySlow(slowDuration);
  }

  @override
  void drawProjectile(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 6, Paint()..color = const Color(0xFF00BFFF));
    canvas.drawCircle(
      Offset.zero,
      9,
      Paint()
        ..color = const Color(0x6600BFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}
