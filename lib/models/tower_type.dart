import 'package:flutter/material.dart';

/// All available defense tower types
enum TowerType { wall, gun, cannon, laser, trap, slow, sniper, auto, mine }

/// Static configuration data for a tower type
class TowerData {
  final TowerType type;
  final String name;
  final String icon;
  final int cost;
  final int maxHp;
  final int damage;
  final double attackCooldown; // seconds between attacks
  final double range; // range in grid cells
  final bool isAreaAttack;
  final double areaRadius; // pixels for area attacks
  final bool slowsEnemies;
  final String description;
  final Color color;

  const TowerData({
    required this.type,
    required this.name,
    required this.icon,
    required this.cost,
    required this.maxHp,
    required this.damage,
    required this.attackCooldown,
    required this.range,
    this.isAreaAttack = false,
    this.areaRadius = 0,
    this.slowsEnemies = false,
    required this.description,
    required this.color,
  });
}

/// All 8 tower definitions – tweak values here for balancing
const List<TowerData> allTowers = [
  TowerData(
    type: TowerType.wall,
    name: 'Muro',
    icon: '🧱',
    cost: 50,
    maxHp: 600,
    damage: 0,
    attackCooldown: 0,
    range: 0,
    description: 'Blocca i nemici',
    color: Color(0xFF8B6914),
  ),
  TowerData(
    type: TowerType.gun,
    name: 'Pistola',
    icon: '🔫',
    cost: 100,
    maxHp: 100,
    damage: 25,
    attackCooldown: 0.5,
    range: 4.0,
    description: 'Sparo veloce',
    color: Color(0xFF4169E1),
  ),
  TowerData(
    type: TowerType.cannon,
    name: 'Cannone',
    icon: '💣',
    cost: 150,
    maxHp: 150,
    damage: 100,
    attackCooldown: 2.0,
    range: 3.5,
    isAreaAttack: true,
    areaRadius: 80,
    description: 'Danno ad area',
    color: Color(0xFF8B0000),
  ),
  TowerData(
    type: TowerType.laser,
    name: 'Laser',
    icon: '⚡',
    cost: 200,
    maxHp: 80,
    damage: 10,
    attackCooldown: 0.1,
    range: 5.0,
    description: 'Raggio continuo',
    color: Color(0xFFFF4500),
  ),
  TowerData(
    type: TowerType.trap,
    name: 'Trappola',
    icon: '⚙️',
    cost: 75,
    maxHp: 60,
    damage: 200,
    attackCooldown: 5.0,
    range: 0.6,
    isAreaAttack: true,
    areaRadius: 40,
    description: 'Esplosione ravvicinata',
    color: Color(0xFFFF8C00),
  ),
  TowerData(
    type: TowerType.slow,
    name: 'Ghiaccio',
    icon: '❄️',
    cost: 125,
    maxHp: 100,
    damage: 5,
    attackCooldown: 1.0,
    range: 3.0,
    slowsEnemies: true,
    description: 'Rallenta i nemici',
    color: Color(0xFF00BFFF),
  ),
  TowerData(
    type: TowerType.sniper,
    name: 'Cecchino',
    icon: '🎯',
    cost: 175,
    maxHp: 90,
    damage: 150,
    attackCooldown: 3.0,
    range: 9.0,
    description: 'Lungo raggio preciso',
    color: Color(0xFF006400),
  ),
  TowerData(
    type: TowerType.auto,
    name: 'Robot',
    icon: '🤖',
    cost: 125,
    maxHp: 120,
    damage: 12,
    attackCooldown: 0.25,
    range: 2.5,
    description: 'Fuoco rapido',
    color: Color(0xFF708090),
  ),
  // Miniera – passive gold generator
  TowerData(
    type: TowerType.mine,
    name: 'Miniera',
    icon: '⛏️',
    cost: 80,
    maxHp: 80,
    damage: 0,
    attackCooldown: 0,
    range: 0,
    description: '+20 oro ogni 6s',
    color: Color(0xFFFFD700),
  ),
];

/// Look up tower data by type
TowerData towerDataFor(TowerType type) => allTowers.firstWhere((t) => t.type == type);
