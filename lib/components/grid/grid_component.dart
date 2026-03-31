import 'dart:ui';

import 'package:flame/components.dart';

import '../../game/home_defense_game.dart';
import '../../models/tower_type.dart';
import '../towers/auto_tower.dart';
import '../towers/base_tower.dart';
import '../towers/cannon_tower.dart';
import '../towers/gun_tower.dart';
import '../towers/laser_tower.dart';
import '../towers/mine_tower.dart';
import '../towers/slow_tower.dart';
import '../towers/sniper_tower.dart';
import '../towers/trap_tower.dart';
import '../towers/wall_tower.dart';

/// One cell in the grid – stores which tower (if any) is placed here.
class GridCell {
  final int col;
  final int row;
  BaseTower? tower;
  bool isHighlighted = false;

  GridCell({required this.col, required this.row});
}

/// The main grid component.  Handles layout, rendering and tower management.
class GridComponent extends PositionComponent with HasGameReference<HomeDefenseGame> {
  final int cols;
  final int rows;

  late double cellSize;
  late List<List<GridCell>> _cells;

  GridComponent({required this.cols, required this.rows}) : super(priority: 0);

  @override
  Future<void> onLoad() async {
    _cells = List.generate(cols, (col) => List.generate(rows, (row) => GridCell(col: col, row: row)));
  }

  /// Called from [HomeDefenseGame._applyLayout] with the already-computed cell size.
  void resize(Vector2 gameSize, double newCellSize) {
    cellSize = newCellSize;
    size = Vector2(gameSize.x, cellSize * rows);
  }

  // ── Coordinate helpers ─────────────────────────────────────────────────────

  /// Convert a world-space position to (col, row), or null if outside grid.
  (int, int)? getCellAt(Vector2 worldPos) {
    final local = worldPos - absolutePosition;
    if (local.x < 0 || local.y < 0 || local.x >= size.x || local.y >= size.y) {
      return null;
    }
    final col = (local.x / cellSize).floor().clamp(0, cols - 1);
    final row = (local.y / cellSize).floor().clamp(0, rows - 1);
    return (col, row);
  }

  /// World-space top-left of a cell.
  Vector2 cellPosition(int col, int row) => absolutePosition + Vector2(col * cellSize, row * cellSize);

  /// Row index for a world-space y coordinate.
  int rowForY(double worldY) => ((worldY - absolutePosition.y) / cellSize).floor().clamp(0, rows - 1);

  // ── Tower management ────────────────────────────────────────────────────────

  bool canPlaceTower(int col, int row) {
    if (col < 0 || col >= cols || row < 0 || row >= rows) return false;
    return _cells[col][row].tower == null;
  }

  BaseTower? getTowerAt(int col, int row) {
    if (col < 0 || col >= cols || row < 0 || row >= rows) return null;
    return _cells[col][row].tower;
  }

  void placeTowerOfType(TowerType type, int col, int row) {
    final tower = _buildTower(type);
    _cells[col][row].tower = tower;
    tower.gridCol = col;
    tower.gridRow = row;
    // Position relative to this GridComponent
    tower.position = Vector2(col * cellSize, row * cellSize);
    tower.size = Vector2(cellSize, cellSize);
    add(tower);
  }

  void removeTowerAt(int col, int row) {
    final tower = _cells[col][row].tower;
    if (tower != null) {
      tower.removeFromParent();
      _cells[col][row].tower = null;
    }
  }

  void clearAllTowers() {
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        _cells[c][r].tower?.removeFromParent();
        _cells[c][r].tower = null;
        _cells[c][r].isHighlighted = false;
      }
    }
  }

  void highlightCell(int col, int row) {
    clearHighlights();
    if (col >= 0 && col < cols && row >= 0 && row < rows) {
      _cells[col][row].isHighlighted = true;
    }
  }

  void clearHighlights() {
    for (final colList in _cells) {
      for (final cell in colList) {
        cell.isHighlighted = false;
      }
    }
  }

  // ── Rendering ───────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final light = const Color(0xFF5C9E3C);
    final dark = const Color(0xFF4A8B2C);
    final highlightPaint = Paint()..color = const Color(0x88FFFF00);
    final gridLinePaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final previewValidPaint = Paint()..color = const Color(0x4400FF00);
    final previewInvalidPaint = Paint()..color = const Color(0x44FF0000);

    final selectedType = game.selectedTowerType;

    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        final cell = _cells[c][r];

        // Checkerboard background
        canvas.drawRect(rect, Paint()..color = (c + r) % 2 == 0 ? light : dark);

        // Placement preview tint
        if (selectedType != null && cell.tower == null) {
          canvas.drawRect(rect, previewValidPaint);
        } else if (selectedType != null && cell.tower != null) {
          canvas.drawRect(rect, previewInvalidPaint);
        }

        // Selection highlight
        if (cell.isHighlighted) {
          canvas.drawRect(rect, highlightPaint);
        }

        // Grid lines
        canvas.drawRect(rect, gridLinePaint);
      }
    }

    // Draw child components (towers) on top
    super.render(canvas);
  }

  // ── Factory ─────────────────────────────────────────────────────────────────

  BaseTower _buildTower(TowerType type) {
    return switch (type) {
      TowerType.wall => WallTower(),
      TowerType.gun => GunTower(),
      TowerType.cannon => CannonTower(),
      TowerType.laser => LaserTower(),
      TowerType.trap => TrapTower(),
      TowerType.slow => SlowTower(),
      TowerType.sniper => SniperTower(),
      TowerType.auto => AutoTower(),
      TowerType.mine => MineTower(),
    };
  }
}
