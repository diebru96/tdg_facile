import 'dart:math';
import 'package:flutter/painting.dart';

import '../../models/tower_type.dart';
import 'base_tower.dart';

/// A passive gold mine – generates money over time, does not attack.
class MineTower extends BaseTower {
  // Gold produced every [_interval] seconds.
  static const double _interval = 6.0;
  static const int _coinsPerTick = 20;

  double _timer = 0;
  // Coin-burst animation
  double _burstTimer = 0;
  static const double _burstDuration = 0.6;

  MineTower() : super(data: towerDataFor(TowerType.mine));

  @override
  bool performAttack() => false; // Miniera non attacca

  @override
  void update(double dt) {
    // BaseTower.update handles combat; we skip it (no attack data).
    if (damageFlash > 0) damageFlash -= dt;
    if (_burstTimer > 0) _burstTimer -= dt;

    _timer += dt;
    if (_timer >= _interval) {
      _timer -= _interval;
      game.addMoney(_coinsPerTick);
      _burstTimer = _burstDuration;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final cx = w / 2;
    final cy = h / 2;

    // Background
    final bgColor = damageFlash > 0 ? const Color(0xFFCC4400) : const Color(0xFF5C4A00);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), const Radius.circular(6)), Paint()..color = bgColor);

    // Coin icon
    canvas.drawCircle(Offset(cx, cy - h * 0.05), w * 0.25, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(
      Offset(cx, cy - h * 0.05),
      w * 0.25,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw animated coin burst particles
    if (_burstTimer > 0) {
      final progress = 1.0 - (_burstTimer / _burstDuration);
      final rng = Random(42);
      const particleCount = 5;
      for (int i = 0; i < particleCount; i++) {
        final angle = (i / particleCount) * 2 * pi;
        final dist = progress * h * 0.4;
        final px = cx + cos(angle) * dist;
        final py = (cy - h * 0.05) + sin(angle) * dist;
        final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);
        canvas.drawCircle(Offset(px, py), 3, Paint()..color = Color.fromARGB(alpha, 255, 215, 0));
      }
      // suppress unused(rng) warning
      rng.nextBool();
    }

    // HP bar at bottom
    final barW = w * 0.8;
    final ratio = hp / data.maxHp;
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h - 6, barW, 4), Paint()..color = const Color(0xFF333333));
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h - 6, barW * ratio, 4), Paint()..color = ratio > 0.5 ? const Color(0xFF00CC44) : const Color(0xFFFF4400));
  }
}
