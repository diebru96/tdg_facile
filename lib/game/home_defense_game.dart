import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/enemies/base_enemy.dart';
import '../components/grid/grid_component.dart';
import '../components/house/house_component.dart';
import '../models/level_data.dart';
import '../models/tower_type.dart';
import '../systems/economy_system.dart';
import '../systems/wave_system.dart';
import 'game_state.dart';

/// ── HomeDefenseGame ─────────────────────────────────────────────────────────
///
/// Root FlameGame.  All game-logic sub-systems live here and communicate
/// through this object.  Flutter overlay widgets receive updates via the
/// [ChangeNotifier] mixin.
class HomeDefenseGame extends FlameGame with TapCallbacks, ChangeNotifier {
  // ── Layout constants ────────────────────────────────────────────────────────
  static const int gridCols = 8;
  static const int gridRows = 8;

  // ── Core components ─────────────────────────────────────────────────────────
  late final GridComponent grid;
  late final HouseComponent house;

  // ── Sub-systems ─────────────────────────────────────────────────────────────
  late final EconomySystem economySystem;
  late final WaveSystem waveSystem;

  // ── Game state ──────────────────────────────────────────────────────────────
  GameState _state = GameState.menu;

  GameState get state => _state;

  void setState(GameState newState) {
    _state = newState;
    _syncOverlays();
    notifyListeners();
  }

  // ── Observable properties (drive HUD updates) ────────────────────────────────
  int _money = 0;
  int get money => _money;

  int _houseHp = 100;
  int get houseHp => _houseHp;
  int get maxHouseHp => 100;

  int _currentWave = 0;
  int get currentWave => _currentWave;
  int get totalWaves => _currentLevel?.waves.length ?? 0;

  bool _waveInProgress = false;
  bool get waveInProgress => _waveInProgress;

  LevelData? _currentLevel;
  LevelData? get currentLevel => _currentLevel;

  // ── Tower selection (from HUD panel) ────────────────────────────────────────
  TowerType? selectedTowerType;

  // ── Y-coordinate where house starts in game space ───────────────────────────
  double get houseY => grid.position.y + grid.size.y;

  // ── Enemies currently in the scene ──────────────────────────────────────────
  List<BaseEnemy> get activeEnemies => children.whereType<BaseEnemy>().toList();

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    grid = GridComponent(cols: gridCols, rows: gridRows);
    house = HouseComponent();
    economySystem = EconomySystem(game: this);
    waveSystem = WaveSystem(game: this);

    await add(grid);
    await add(house);
    await add(economySystem);
    await add(waveSystem);

    // Start at menu
    overlays.add('mainMenu');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final cellSize = size.x / gridCols;
    final gridH = cellSize * gridRows;

    grid.resize(size);
    grid.position = Vector2.zero();

    house.resize(size, gridH);
    house.position = Vector2(0, gridH);
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Called by [EconomySystem] and towers to update money.
  void addMoney(int amount) {
    _money += amount;
    notifyListeners();
  }

  /// Returns true and deducts cost if player can afford it.
  bool spendMoney(int cost) {
    if (_money < cost) return false;
    _money -= cost;
    notifyListeners();
    return true;
  }

  /// Called when the house takes damage.
  void damageHouse(int amount) {
    _houseHp = (_houseHp - amount).clamp(0, maxHouseHp);
    notifyListeners();
    if (_houseHp <= 0) _triggerGameOver();
  }

  /// Called by [WaveSystem] on wave progression.
  void updateWaveInfo({required int current, required bool inProgress}) {
    _currentWave = current;
    _waveInProgress = inProgress;
    notifyListeners();
  }

  /// Start (or restart) the game with a given level.
  void startLevel(LevelData level) {
    _currentLevel = level;
    _money = level.startingMoney;
    _houseHp = maxHouseHp;
    _currentWave = 0;
    _waveInProgress = false;
    selectedTowerType = null;

    // Clear previous game objects
    grid.clearAllTowers();
    for (final e in activeEnemies) {
      e.removeFromParent();
    }

    house.reset();
    economySystem.reset(level);
    waveSystem.reset(level);

    setState(GameState.playing);
  }

  void pauseGame() {
    if (_state == GameState.playing) {
      setState(GameState.paused);
      pauseEngine();
    }
  }

  void resumeGame() {
    if (_state == GameState.paused) {
      setState(GameState.playing);
      resumeEngine();
    }
  }

  void goToMenu() {
    resumeEngine();
    setState(GameState.menu);
  }

  // ── Tap handling ─────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (_state != GameState.playing) return;
    if (selectedTowerType == null) return;

    final worldPos = event.canvasPosition;
    final cell = grid.getCellAt(worldPos);
    if (cell == null) return;

    final (col, row) = cell;
    if (!grid.canPlaceTower(col, row)) return;

    final data = towerDataFor(selectedTowerType!);
    if (!spendMoney(data.cost)) {
      // Not enough money – flash the HUD (overlay reacts to notifyListeners)
      notifyListeners();
      return;
    }

    grid.placeTowerOfType(selectedTowerType!, col, row);
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  void _triggerGameOver() {
    setState(GameState.gameOver);
  }

  void _triggerWin() {
    setState(GameState.win);
  }

  /// Public method to trigger a UI refresh from overlay widgets.
  void refresh() => notifyListeners();

  /// Called by WaveSystem when all waves are complete and no enemies remain.
  void onAllWavesComplete() {
    _triggerWin();
  }

  void _syncOverlays() {
    // Remove all managed overlays then re-add relevant ones
    const managed = ['mainMenu', 'hud', 'towerPanel', 'gameOver', 'win', 'levelSelect'];
    for (final o in managed) {
      overlays.remove(o);
    }

    switch (_state) {
      case GameState.menu:
        overlays.add('mainMenu');
      case GameState.levelSelect:
        overlays.add('levelSelect');
      case GameState.playing:
      case GameState.paused:
        overlays.add('hud');
        overlays.add('towerPanel');
      case GameState.gameOver:
        overlays.add('hud');
        overlays.add('gameOver');
      case GameState.win:
        overlays.add('hud');
        overlays.add('win');
    }
  }
}
