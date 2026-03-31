import 'package:flutter/material.dart';

import '../game/game_state.dart';
import '../game/home_defense_game.dart';
import '../models/tower_type.dart';

/// Top HUD bar showing money, house HP and wave info.
class HudOverlay extends StatefulWidget {
  final HomeDefenseGame game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.game.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final hpRatio = game.houseHp / game.maxHouseHp;

    return SafeArea(
      child: Column(
        children: [
          // ── Top status bar ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
            ),
            child: Row(
              children: [
                // Money
                _StatChip(icon: '💰', label: '${game.money}', color: const Color(0xFFFFD700)),
                const SizedBox(width: 16),
                // House HP bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏠 ', style: TextStyle(fontSize: 14)),
                          Text('${game.houseHp} / ${game.maxHouseHp}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hpRatio,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation(
                            hpRatio > 0.5
                                ? Colors.green
                                : hpRatio > 0.25
                                ? Colors.orange
                                : Colors.red,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Wave
                _StatChip(icon: '🌊', label: '${game.currentWave} / ${game.totalWaves}', color: Colors.lightBlueAccent),
                const SizedBox(width: 8),
                // Pause button
                GestureDetector(
                  onTap: () => game.state == GameState.playing ? game.pauseGame() : game.resumeGame(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(game.state == GameState.playing ? '⏸' : '▶️', style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── Tower selection panel ─────────────────────────────────────────────────────

/// Bottom panel showing all 8 towers for the player to choose from.
class TowerPanelOverlay extends StatefulWidget {
  final HomeDefenseGame game;
  const TowerPanelOverlay({super.key, required this.game});

  @override
  State<TowerPanelOverlay> createState() => _TowerPanelOverlayState();
}

class _TowerPanelOverlayState extends State<TowerPanelOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.game.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Deselect hint
              if (game.selectedTowerType != null)
                GestureDetector(
                  onTap: () {
                    game.selectedTowerType = null;
                    game.grid?.clearHighlights();
                    game.refresh();
                  },
                  child: const Text('Tap di nuovo per deselezionare', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ),
              const SizedBox(height: 4),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allTowers.length,
                  itemBuilder: (ctx, idx) {
                    final td = allTowers[idx];
                    final canAfford = game.money >= td.cost;
                    final isSelected = game.selectedTowerType == td.type;

                    return GestureDetector(
                      onTap: canAfford
                          ? () {
                              if (game.selectedTowerType == td.type) {
                                game.selectedTowerType = null;
                                game.grid?.clearHighlights();
                              } else {
                                game.selectedTowerType = td.type;
                              }
                              game.refresh();
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? td.color.withAlpha(220) : Colors.grey[850],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.yellow
                                : canAfford
                                ? td.color.withAlpha(180)
                                : Colors.grey[700]!,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: canAfford ? 1.0 : 0.4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(td.icon, style: const TextStyle(fontSize: 24)),
                              Text(
                                td.name,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              Text('💰${td.cost}', style: TextStyle(color: canAfford ? const Color(0xFFFFD700) : Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
