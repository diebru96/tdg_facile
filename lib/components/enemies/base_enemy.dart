import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../game/home_defense_game.dart';
import '../../models/enemy_type.dart';

/// Abstract base for all enemy types.
///
/// Enemies are direct children of the root [HomeDefenseGame].
/// They move in a vertical column at a given X position and deal
/// damage to the house when they reach [gameRef.houseY].
abstract class BaseEnemy extends PositionComponent with HasGameReference<HomeDefenseGame> {
  final EnemyData data;

  /// Grid column the enemy is walking through.
  final int column;

  late int _hp;
  double _currentSpeed;

  // Slow effect
  bool _isSlowed = false;
  double _slowTimer = 0;

  // Blocking: enemy attacking a tower in its path
  double _attackTimer = 0;
  static const double _attackInterval = 1.0; // seconds between enemy hits
  static const int _attackDamage = 20; // damage enemy deals to tower

  // Death flag
  bool isDead = false;

  // Flash when hit
  double _hitFlash = 0;

  BaseEnemy({required this.data, required this.column, Vector2? enemySize})
    : _currentSpeed = data.speed,
      super(size: enemySize ?? Vector2(32, 32), priority: 3);

  @override
  Future<void> onLoad() async {
    _hp = data.maxHp;
  }

  // ── World coordinates ────────────────────────────────────────────────────────

  /// Centre of the enemy in game (world) coordinates.
  Vector2 get worldCenter => absolutePosition + size / 2;

  // ── Damage API ───────────────────────────────────────────────────────────────

  void takeDamage(int damage) {
    if (isDead) return;
    final actual = (damage * data.armorMultiplier).round();
    _hp -= actual;
    _hitFlash = 0.12;
    if (_hp <= 0) _die();
  }

  void applySlow(double duration) {
    if (!_isSlowed) _currentSpeed = data.speed * 0.35;
    _isSlowed = true;
    _slowTimer = duration.clamp(_slowTimer, 999);
  }

  void _die() {
    isDead = true;
    game.economySystem.addMoney(data.reward);
    game.waveSystem.onEnemyDefeated();
    removeFromParent();
  }

  // ── Update ───────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    if (_hitFlash > 0) _hitFlash -= dt;

    // Decay slow
    if (_isSlowed) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) {
        _isSlowed = false;
        _currentSpeed = data.speed;
      }
    }

    // Check for a tower in the cell directly below
    final grid = game.grid;
    final bottomY = position.y + size.y;
    final nextRow = grid.rowForY(bottomY + 2); // +2 px look-ahead
    final blockingTower = grid.getTowerAt(column, nextRow);

    if (blockingTower != null && !data.ignoresWalls) {
      // Attack the tower
      _attackTimer += dt;
      if (_attackTimer >= _attackInterval) {
        _attackTimer = 0;
        blockingTower.takeDamage(_attackDamage);
      }
      return; // stop moving while blocked
    }

    // Move downward
    position.y += _currentSpeed * dt;

    // Arrived at house?
    if (position.y + size.y >= game.houseY) {
      game.damageHouse(data.damage);
      isDead = true;
      game.waveSystem.onEnemyDefeated();
      removeFromParent();
    }
  }

  // ── Render ───────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Body
    drawBody(canvas);

    // Slow ice overlay
    if (_isSlowed) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = const Color(0x5500BFFF));
    }

    // Hit flash
    if (_hitFlash > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = const Color(0x88FF0000));
    }

    // Icon
    _drawEmoji(canvas, data.icon, size / 2, size.y * 0.5);

    // HP bar
    _drawHpBar(canvas);
  }

  /// Override to draw the enemy body shape/colour (called before icon).
  void drawBody(Canvas canvas);

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

  void _drawHpBar(Canvas canvas) {
    final ratio = (_hp / data.maxHp).clamp(0.0, 1.0);
    const bh = 4.0;
    final by = -7.0;

    canvas.drawRect(Rect.fromLTWH(0, by, size.x, bh), Paint()..color = const Color(0xFF222222));
    canvas.drawRect(
      Rect.fromLTWH(0, by, size.x * ratio, bh),
      Paint()
        ..color = ratio > 0.5
            ? const Color(0xFF00CC44)
            : ratio > 0.25
            ? const Color(0xFFFF8800)
            : const Color(0xFFCC0000),
    );
  }
}
