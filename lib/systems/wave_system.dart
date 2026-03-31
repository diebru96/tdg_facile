import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemies/armored_thief.dart';
import '../components/enemies/base_enemy.dart';
import '../components/enemies/fast_thief.dart';
import '../components/enemies/special_thief.dart';
import '../components/enemies/tank_thief.dart';
import '../game/home_defense_game.dart';
import '../models/enemy_type.dart';
import '../models/level_data.dart';

/// Manages wave progression: spawns enemies, waits for clear, advances.
class WaveSystem extends Component with HasGameReference<HomeDefenseGame> {
  static const double _betweenWaveDelay = 5.0;

  late LevelData _level;
  int _waveIndex = 0;
  bool _levelLoaded = false;

  // Spawn queue built each wave
  final List<_SpawnEntry> _queue = [];
  double _spawnTimer = 0;
  int _aliveEnemies = 0;
  bool _spawningFinished = false;
  double _interWaveTimer = 0;
  bool _waitingForNextWave = false;

  final _rng = Random();

  WaveSystem({required HomeDefenseGame game});

  void reset(LevelData level) {
    _level = level;
    _waveIndex = 0;
    _levelLoaded = true;
    _queue.clear();
    _aliveEnemies = 0;
    _spawningFinished = false;
    _waitingForNextWave = false;
    _interWaveTimer = 0;
    game.updateWaveInfo(current: 0, inProgress: false);
    // Start first wave after a short grace period
    _interWaveTimer = 3.0;
    _waitingForNextWave = true;
  }

  // Called from BaseEnemy when it dies or reaches the house
  void onEnemyDefeated() {
    _aliveEnemies = (_aliveEnemies - 1).clamp(0, 9999);
    _checkWaveComplete();
  }

  void _checkWaveComplete() {
    if (_spawningFinished && _aliveEnemies == 0) {
      final bonus = _level.waves[_waveIndex].moneyBonus;
      game.addMoney(bonus);
      _waveIndex++;

      if (_waveIndex >= _level.waves.length) {
        // All waves done!
        game.updateWaveInfo(current: _level.waves.length, inProgress: false);
        game.onAllWavesComplete();
        return;
      }

      _waitingForNextWave = true;
      _interWaveTimer = _betweenWaveDelay;
      game.updateWaveInfo(current: _waveIndex, inProgress: false);
    }
  }

  void _startWave(int index) {
    final wave = _level.waves[index];
    _queue.clear();
    _spawningFinished = false;

    double delay = 0;
    for (final group in wave.groups) {
      for (int i = 0; i < group.count; i++) {
        _queue.add(_SpawnEntry(type: group.type, delay: delay));
        delay += group.spawnInterval;
      }
    }
    // Sort by delay so we process in order
    _queue.sort((a, b) => a.delay.compareTo(b.delay));
    _aliveEnemies = _queue.length;
    _spawnTimer = 0;
    _waitingForNextWave = false;

    game.updateWaveInfo(current: index + 1, inProgress: true);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_levelLoaded) return;
    if (game.state.index != 1) return; // playing state index = 1

    if (_waitingForNextWave) {
      _interWaveTimer -= dt;
      if (_interWaveTimer <= 0) {
        _startWave(_waveIndex);
      }
      return;
    }

    if (_spawningFinished) return;

    _spawnTimer += dt;

    // Spawn all enemies whose delay has been reached
    while (_queue.isNotEmpty && _spawnTimer >= _queue.first.delay) {
      final entry = _queue.removeAt(0);
      _spawnEnemy(entry.type);
    }

    if (_queue.isEmpty) {
      _spawningFinished = true;
      _checkWaveComplete();
    }
  }

  void _spawnEnemy(EnemyType type) {
    final col = _rng.nextInt(HomeDefenseGame.gridCols);
    final enemy = _buildEnemy(type, col);

    // Spawn just above the visible grid
    final x = game.grid.absolutePosition.x + col * game.grid.cellSize + game.grid.cellSize / 2 - enemy.size.x / 2;
    enemy.position = Vector2(x, -enemy.size.y - 4);

    game.add(enemy);
  }

  BaseEnemy _buildEnemy(EnemyType type, int col) {
    return switch (type) {
      EnemyType.fast => FastThief(column: col),
      EnemyType.tank => TankThief(column: col),
      EnemyType.armored => ArmoredThief(column: col),
      EnemyType.special => SpecialThief(column: col),
    };
  }
}

class _SpawnEntry {
  final EnemyType type;
  final double delay;
  const _SpawnEntry({required this.type, required this.delay});
}
