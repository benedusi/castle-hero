// UI layer stub for future milestone
// This milestone focuses on the pure Dart engine only
// The UI will render GameState and emit Moves to drive the engine

// Example integration (future):
// 
// class BattleScreen extends StatefulWidget { ... }
// 
// The screen would:
// 1. Hold a GameState
// 2. Render it (health bars, cards, resources)
// 3. On card tap: create PlayAttackerCard move, call applyMove
// 4. On AI turn: call chooseDefenderMove, then applyMove
// 5. Update UI when state changes
