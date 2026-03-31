import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../game/home_defense_game.dart';
import '../../models/tower_type.dart';
import '../enemies/base_enemy.dart';

/// Abstract base for all tower types.
///
/// Towers are children of [GridComponent], so their [position] is grid-local.
/// They find enemies through [game.activeEnemies] which are direct children
/// of the game root.
abstract class BaseTower extends PositionComponent with HasGameReference<HomeDefenseGame> {
  final TowerData data;

  int gridCol = 0;
  int gridRow = 0;

  late int _hp;
  double _attackTimer = 0;

  // Flash effect when damaged – exposed as protected for subclasses that
  // override update() (e.g. MineTower).
  double damageFlash = 0;

  int get hp => _hp;
  bool get isDestroyed => _hp <= 0;

  BaseTower({required this.data}) : super(priority: 2);

  @override
  Future<void> onLoad() async {
    _hp = data.maxHp;
  }

  // ── Damage ───────────────────────────────────────────────────────────────────

  void takeDamage(int amount) {
    _hp -= amount;
    damageFlash = 0.15;
    if (_hp <= 0) {
      game.grid!.removeTowerAt(gridCol, gridRow);
    }
  }

  // ── Range helper ─────────────────────────────────────────────────────────────

  /// Returns the range radius in pixels.
  double get rangePixels => data.range * game.grid!.cellSize;

  /// Centre of this tower in game (world) coordinates.
  Vector2 get worldCenter => game.grid!.absolutePosition + Vector2((gridCol + 0.5) * game.grid!.cellSize, (gridRow + 0.5) * game.grid!.cellSize);

  /// Nearest enemy within range, or null.
  BaseEnemy? nearestEnemyInRange() {
    BaseEnemy? best;
    double bestDist = double.infinity;
    for (final enemy in game.activeEnemies) {
      final d = (enemy.worldCenter - worldCenter).length;
      if (d < rangePixels && d < bestDist) {
        bestDist = d;
        best = enemy;
      }
    }
    return best;
  }

  /// All enemies within range (for area attacks).
  List<BaseEnemy> enemiesInRange() {
    return game.activeEnemies.where((e) => (e.worldCenter - worldCenter).length < rangePixels).toList();
  }

  // ── Update ───────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    if (isDestroyed) return;
    if (damageFlash > 0) damageFlash -= dt;

    if (data.attackCooldown <= 0) return; // walls don't attack

    _attackTimer -= dt;
    if (_attackTimer <= 0) {
      if (performAttack()) {
        _attackTimer = data.attackCooldown;
      }
    }
  }

  /// Execute an attack. Return true if an attack was actually performed.
  bool performAttack();

  // ── Rendering ─────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBackground(canvas);
    drawTower(canvas);
    _drawHealthBar(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(2, 2, size.x - 4, size.y - 4);
    final color = damageFlash > 0 ? const Color(0xFFFF4444) : data.color.withAlpha(200);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawHealthBar(Canvas canvas) {
    if (_hp >= data.maxHp) return;
    final ratio = _hp / data.maxHp;
    final bw = size.x - 8;
    canvas.drawRect(Rect.fromLTWH(4, size.y - 6, bw, 4), Paint()..color = const Color(0xFF222222));
    canvas.drawRect(
      Rect.fromLTWH(4, size.y - 6, bw * ratio, 4),
      Paint()
        ..color = ratio > 0.5
            ? const Color(0xFF00DD44)
            : ratio > 0.25
            ? const Color(0xFFFF8800)
            : const Color(0xFFDD0000),
    );
  }

  /// Override in subclasses to draw the tower icon / appearance.
  void drawTower(Canvas canvas) {
    _drawEmoji(canvas, data.icon, size / 2, size.y * 0.45);
  }

  /// Utility: paint an emoji centered on [center] with [fontSize].
  void drawEmoji(Canvas canvas, String emoji, Offset center, double fontSize) {
    _drawEmoji(canvas, emoji, Vector2(center.dx, center.dy), fontSize);
  }

  void _drawEmoji(Canvas canvas, String text, Vector2 center, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.x - tp.width / 2, center.y - tp.height / 2));
  }
}
