import 'enemy_type.dart';

/// Configuration for a group of enemies to spawn in a wave
class WaveEnemy {
  final EnemyType type;
  final int count;
  final double spawnInterval; // seconds between each spawn

  const WaveEnemy({required this.type, required this.count, required this.spawnInterval});
}

/// A single wave of enemies
class WaveData {
  final int waveNumber;
  final List<WaveEnemy> groups;
  final int moneyBonus; // awarded after completing the wave

  const WaveData({required this.waveNumber, required this.groups, required this.moneyBonus});
}

/// Full configuration for a level
class LevelData {
  final int level;
  final String title;
  final int startingMoney;
  final double moneyInterval; // seconds to generate money
  final int moneyAmount; // coins generated each tick
  final List<WaveData> waves;

  const LevelData({
    required this.level,
    required this.title,
    required this.startingMoney,
    required this.moneyInterval,
    required this.moneyAmount,
    required this.waves,
  });
}

// ── Level definitions ────────────────────────────────────────────────────────

final List<LevelData> gameLevels = [
  // Level 1 – Quiet Night
  const LevelData(
    level: 1,
    title: 'Notte Tranquilla',
    startingMoney: 200,
    moneyInterval: 8.0,
    moneyAmount: 25,
    waves: [
      WaveData(waveNumber: 1, groups: [WaveEnemy(type: EnemyType.fast, count: 5, spawnInterval: 2.0)], moneyBonus: 50),
      WaveData(
        waveNumber: 2,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 6, spawnInterval: 1.5),
          WaveEnemy(type: EnemyType.tank, count: 2, spawnInterval: 3.0),
        ],
        moneyBonus: 75,
      ),
      WaveData(
        waveNumber: 3,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 8, spawnInterval: 1.0),
          WaveEnemy(type: EnemyType.tank, count: 3, spawnInterval: 2.5),
          WaveEnemy(type: EnemyType.armored, count: 2, spawnInterval: 3.0),
        ],
        moneyBonus: 100,
      ),
    ],
  ),

  // Level 2 – Neighbourhood Alert
  const LevelData(
    level: 2,
    title: 'Allarme nel Quartiere',
    startingMoney: 150,
    moneyInterval: 7.0,
    moneyAmount: 20,
    waves: [
      WaveData(
        waveNumber: 1,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 8, spawnInterval: 1.5),
          WaveEnemy(type: EnemyType.armored, count: 3, spawnInterval: 2.5),
        ],
        moneyBonus: 80,
      ),
      WaveData(
        waveNumber: 2,
        groups: [
          WaveEnemy(type: EnemyType.tank, count: 5, spawnInterval: 2.0),
          WaveEnemy(type: EnemyType.armored, count: 4, spawnInterval: 2.0),
        ],
        moneyBonus: 100,
      ),
      WaveData(
        waveNumber: 3,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 10, spawnInterval: 0.8),
          WaveEnemy(type: EnemyType.tank, count: 5, spawnInterval: 1.5),
          WaveEnemy(type: EnemyType.special, count: 3, spawnInterval: 3.0),
        ],
        moneyBonus: 150,
      ),
      WaveData(
        waveNumber: 4,
        groups: [
          WaveEnemy(type: EnemyType.armored, count: 8, spawnInterval: 1.0),
          WaveEnemy(type: EnemyType.special, count: 5, spawnInterval: 2.0),
        ],
        moneyBonus: 200,
      ),
    ],
  ),

  // Level 3 – Full Siege
  const LevelData(
    level: 3,
    title: 'Assedio Totale',
    startingMoney: 100,
    moneyInterval: 6.0,
    moneyAmount: 15,
    waves: [
      WaveData(
        waveNumber: 1,
        groups: [
          WaveEnemy(type: EnemyType.armored, count: 5, spawnInterval: 2.0),
          WaveEnemy(type: EnemyType.special, count: 3, spawnInterval: 2.0),
        ],
        moneyBonus: 100,
      ),
      WaveData(
        waveNumber: 2,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 15, spawnInterval: 0.5),
          WaveEnemy(type: EnemyType.special, count: 5, spawnInterval: 1.5),
        ],
        moneyBonus: 120,
      ),
      WaveData(
        waveNumber: 3,
        groups: [
          WaveEnemy(type: EnemyType.tank, count: 8, spawnInterval: 1.5),
          WaveEnemy(type: EnemyType.armored, count: 8, spawnInterval: 1.0),
        ],
        moneyBonus: 150,
      ),
      WaveData(
        waveNumber: 4,
        groups: [
          WaveEnemy(type: EnemyType.fast, count: 12, spawnInterval: 0.5),
          WaveEnemy(type: EnemyType.tank, count: 6, spawnInterval: 1.0),
          WaveEnemy(type: EnemyType.armored, count: 8, spawnInterval: 0.8),
          WaveEnemy(type: EnemyType.special, count: 4, spawnInterval: 2.0),
        ],
        moneyBonus: 200,
      ),
      WaveData(
        waveNumber: 5,
        groups: [
          WaveEnemy(type: EnemyType.special, count: 10, spawnInterval: 0.8),
          WaveEnemy(type: EnemyType.tank, count: 10, spawnInterval: 0.8),
          WaveEnemy(type: EnemyType.armored, count: 10, spawnInterval: 0.8),
        ],
        moneyBonus: 300,
      ),
    ],
  ),
];
