/// All possible states the game can be in
enum GameState {
  menu, // Main menu screen
  levelSelect, // Level selection screen
  playing, // Active gameplay
  paused, // Game paused
  gameOver, // Player lost (house HP = 0)
  win, // Player won all waves
}
