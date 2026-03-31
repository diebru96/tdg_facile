import 'dart:ui';

import '../../models/tower_type.dart';
import 'base_tower.dart';

/// High-HP wall that physically blocks enemies from passing.
class WallTower extends BaseTower {
  WallTower() : super(data: towerDataFor(TowerType.wall));

  @override
  bool performAttack() => false; // walls never attack

  @override
  void drawTower(Canvas canvas) {
    // Draw brick pattern
    final brickPaint = Paint()..color = const Color(0xFFA0522D);
    final mortarPaint = Paint()..color = const Color(0xFFD2B48C);

    canvas.drawRect(Rect.fromLTWH(4, 4, size.x - 8, size.y - 8), mortarPaint);

    const bRows = 4;
    const bCols = 3;
    final bw = (size.x - 8) / bCols;
    final bh = (size.y - 8) / bRows;

    for (int r = 0; r < bRows; r++) {
      final offset = (r % 2 == 0) ? 0.0 : bw / 2;
      for (int c = -1; c <= bCols; c++) {
        final rx = 4 + c * bw + offset;
        final ry = 4 + r * bh;
        canvas.drawRect(Rect.fromLTWH(rx + 1, ry + 1, bw - 2, bh - 2), brickPaint);
      }
    }
    drawEmoji(canvas, data.icon, Offset(size.x / 2, size.y / 2), 14);
  }
}
