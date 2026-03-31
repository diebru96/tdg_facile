import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../game/home_defense_game.dart';

/// The house the player must protect.  Lives below the grid.
class HouseComponent extends PositionComponent with HasGameRef<HomeDefenseGame> {
  static const int maxHp = 100;
  int _hp = maxHp;

  int get hp => _hp;
  bool get isDestroyed => _hp <= 0;

  // Attack flash effect
  double _flashTimer = 0;
  static const double _flashDuration = 0.3;

  @override
  Future<void> onLoad() async {
    priority = 1;
  }

  void resize(Vector2 gameSize, double gridBottom) {
    size = Vector2(gameSize.x, gameSize.y - gridBottom);
  }

  void reset() {
    _hp = maxHp;
    _flashTimer = 0;
  }

  void takeDamage(int amount) {
    _hp = (_hp - amount).clamp(0, maxHp);
    _flashTimer = _flashDuration;
    gameRef.damageHouse(amount);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) _flashTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // House base
    final isFlashing = _flashTimer > 0;
    final baseColor = isFlashing ? const Color(0xFFCC2200) : const Color(0xFF3D5A80);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = baseColor);

    // Roof
    final roofPath = Path()
      ..moveTo(0, h * 0.35)
      ..lineTo(w / 2, 0)
      ..lineTo(w, h * 0.35)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF8B2500));

    // Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.4, h * 0.55, w * 0.2, h * 0.45), const Radius.circular(4)),
      Paint()..color = const Color(0xFF5C3D2E),
    );

    // Windows
    for (final wx in [0.15, 0.65]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * wx, h * 0.5, w * 0.15, h * 0.2), const Radius.circular(2)),
        Paint()..color = const Color(0xFFADD8E6),
      );
    }

    // "FACILE" alarm panel label
    _drawText(canvas, '🔒 FACILE', Offset(w * 0.5, h * 0.88), 12);

    // HP bar
    final barW = w * 0.8;
    final barH = 8.0;
    final barX = w * 0.1;
    final barY = h - 12;
    final ratio = _hp / maxHp;

    canvas.drawRect(Rect.fromLTWH(barX, barY, barW, barH), Paint()..color = const Color(0xFF333333));
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barW * ratio, barH),
      Paint()
        ..color = ratio > 0.5
            ? const Color(0xFF00CC44)
            : ratio > 0.25
            ? const Color(0xFFFF8800)
            : const Color(0xFFCC0000),
    );
  }

  void _drawText(Canvas canvas, String text, Offset center, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: const Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
}
