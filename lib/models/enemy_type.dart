/// All enemy types in the game
enum EnemyType { fast, tank, armored, special }

/// Static configuration data for an enemy type
class EnemyData {
  final EnemyType type;
  final String name;
  final String icon;
  final int maxHp;
  final double speed; // pixels per second
  final int damage; // damage dealt to house on arrival
  final int reward; // money earned on kill
  final double armorMultiplier; // 1.0 = no armor, 0.5 = half damage
  final bool ignoresWalls; // can walk through towers
  final bool explodes; // deals splash damage on death

  const EnemyData({
    required this.type,
    required this.name,
    required this.icon,
    required this.maxHp,
    required this.speed,
    required this.damage,
    required this.reward,
    this.armorMultiplier = 1.0,
    this.ignoresWalls = false,
    this.explodes = false,
  });
}

const Map<EnemyType, EnemyData> enemyDataMap = {
  EnemyType.fast: EnemyData(type: EnemyType.fast, name: 'Borseggiatore', icon: '🏃', maxHp: 60, speed: 75.0, damage: 10, reward: 15),
  EnemyType.tank: EnemyData(type: EnemyType.tank, name: 'Bullo', icon: '🦍', maxHp: 350, speed: 30.0, damage: 25, reward: 30),
  EnemyType.armored: EnemyData(
    type: EnemyType.armored,
    name: 'Blindato',
    icon: '🥷',
    maxHp: 200,
    speed: 45.0,
    damage: 20,
    reward: 25,
    armorMultiplier: 0.5,
  ),
  EnemyType.special: EnemyData(
    type: EnemyType.special,
    name: 'Fantasma',
    icon: '👻',
    maxHp: 100,
    speed: 65.0,
    damage: 30,
    reward: 40,
    ignoresWalls: true,
  ),
};
