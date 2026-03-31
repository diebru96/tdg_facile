import 'package:flutter/material.dart';

import '../game/game_state.dart';
import '../game/home_defense_game.dart';
import '../models/level_data.dart';

// ── Main Menu ─────────────────────────────────────────────────────────────────

class MainMenuOverlay extends StatelessWidget {
  final HomeDefenseGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC0D0D1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏠', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              const Text(
                'HOME DEFENSE',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
              const SizedBox(height: 4),
              const Text('Proteggi la tua casa dagli intrusi!', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 48),
              _MenuButton(label: 'GIOCA', icon: '▶️', onTap: () => game.setState(GameState.levelSelect)),
              const SizedBox(height: 16),
              _InfoBox(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Level Select ──────────────────────────────────────────────────────────────

class LevelSelectOverlay extends StatelessWidget {
  final HomeDefenseGame game;
  const LevelSelectOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'SELEZIONA LIVELLO',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gameLevels.length,
                itemBuilder: (ctx, idx) {
                  final level = gameLevels[idx];
                  return _LevelCard(level: level, onTap: () => game.startLevel(level));
                },
              ),
            ),
            TextButton(
              onPressed: () => game.goToMenu(),
              child: const Text('← MENU', style: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final VoidCallback onTap;
  const _LevelCard({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficulties = ['⭐', '⭐⭐', '⭐⭐⭐'];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFF1A3A5C), const Color(0xFF0D1A2E)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withAlpha(120)),
        ),
        child: Row(
          children: [
            Text(
              '${level.level}',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${level.waves.length} ondate  •  '
                    'Soldi iniziali: 💰${level.startingMoney}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(difficulties[level.level - 1], style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ── Game Over ─────────────────────────────────────────────────────────────────

class GameOverOverlay extends StatelessWidget {
  final HomeDefenseGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _EndScreen(title: 'GAME OVER', subtitle: 'La tua casa è stata violata!', emoji: '💀', accentColor: Colors.red, game: game);
  }
}

// ── Win Screen ────────────────────────────────────────────────────────────────

class WinOverlay extends StatelessWidget {
  final HomeDefenseGame game;
  const WinOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _EndScreen(
      title: 'LIVELLO COMPLETATO!',
      subtitle: 'Tutti gli intrusi sono stati respinti!',
      emoji: '🏆',
      accentColor: Colors.amber,
      game: game,
    );
  }
}

// ── Shared end-screen widget ──────────────────────────────────────────────────

class _EndScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final HomeDefenseGame game;

  const _EndScreen({required this.title, required this.subtitle, required this.emoji, required this.accentColor, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withAlpha(180), width: 2),
            boxShadow: [BoxShadow(color: accentColor.withAlpha(80), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _MenuButton(
                label: 'RIPROVA',
                icon: '🔄',
                onTap: () {
                  if (game.currentLevel != null) {
                    game.startLevel(game.currentLevel!);
                  }
                },
              ),
              const SizedBox(height: 12),
              _MenuButton(label: 'MENU PRINCIPALE', icon: '🏠', onTap: game.goToMenu),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A4A8C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('$icon  $label', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 Come giocare',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 6),
          Text('• Seleziona una difesa dal pannello in basso', style: TextStyle(color: Colors.white54, fontSize: 11)),
          Text('• Tocca una cella della griglia per posizionarla', style: TextStyle(color: Colors.white54, fontSize: 11)),
          Text('• La centrale FACILE genera denaro automaticamente', style: TextStyle(color: Colors.white54, fontSize: 11)),
          Text('• Sopravvivi a tutte le ondate per vincere!', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
