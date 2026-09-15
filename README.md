# Siege — Castle Hero

A card-based siege game for mobile. Command a besieging army, take castle after castle in a card duel, and march to the crown.

**Status**: Milestone 2 complete — Pure Dart engine + Flutter UI. Playable single-player campaign with AI opponent across 5 difficulty tiers.

## Architecture

The project follows a strict separation between game logic and UI:

```
lib/
  engine/          # Pure Dart — NO Flutter imports
    cards.dart     # Card definitions and deck building
    game_state.dart # GameState, PlayerState, DefenderState (JSON-serializable)
    move.dart      # Move types (PlayCard, Discard)
    engine.dart    # Core: applyMove(GameState, Move) -> GameState
    ai.dart        # Defender AI: chooseDefenderMove(GameState) -> Move
  
  campaign/        # Pure Dart — NO Flutter imports
    tiers.dart     # Difficulty tier definitions
    campaign.dart  # Campaign progression state
  
  ui/              # Flutter UI layer
    game_controller.dart  # State management (ChangeNotifier)
    theme.dart            # Dark medieval theme
    screens/
      campaign_map_screen.dart  # Campaign map with 5 nodes
      battle_screen.dart        # Battle UI
    widgets/
      health_bar.dart       # Health pool visualization
      resource_display.dart # Stone, food, gold
      card_widget.dart      # Card rendering
      battle_log.dart       # Recent events
      battle_overlay.dart   # Win/loss/crowned overlay
  
  main.dart        # App entry point
  
test/
  engine_test.dart      # Unit tests for core engine
  simulation_test.dart  # Simulation harness proving games terminate
  campaign_test.dart    # Campaign progression tests
```

### Design Principles

1. **Transport-agnostic state machine**: The engine is a pure function `applyMove(GameState, Move) -> GameState`. Every game mode (single-player, hotseat, Bluetooth, online) is just a different source of moves feeding this same core.

2. **JSON-serializable state**: `GameState` and all substates are fully JSON-serializable, ready for save/load, network sync, or debugging.

3. **No Flutter in engine**: All game logic (`lib/engine/`, `lib/campaign/`) is pure Dart with zero Flutter imports. The engine can be unit-tested headless and integrated into any UI framework.

4. **Deterministic and testable**: Given the same state and move, `applyMove` always produces the same result. The AI uses seeded randomness for reproducibility when needed.

## Game Rules

### Core Mechanics

- **Two health pools**: The castle's wall (defender) and the player's catapult (attacker).
- **No repair**: Health only goes down. This creates a depletion race that guarantees game termination.
- **Resources**: Stone, food, and gold. Start at 5 each, +1/turn, capped at 25.
- **Hand size**: 3 cards. Deck reshuffles when empty.
- **Turn sequence**:
  1. Income (+1 of each resource)
  2. Resolve persistent effects (fire DoT, infantry upkeep & damage)
  3. Play or discard one card
  4. Draw back to 3

### Win Conditions

- **Attacker wins** if wall ≤ 0
- **Defender wins** if catapult ≤ 0

### Attacker Cards (Player)

| Card | Tier | Cost | Effect |
|------|------|------|--------|
| Fire | 1 | 3 stone | 5 damage to wall |
| Volley | 2 | 6 stone | 12 damage to wall |
| Infantry | 2 | 5 food | Deploy unit: 2 food/turn, deals 1 damage (max 2) |
| Fireball | 3 | 3 stone + 5 gold | 5 immediate + fire DoT (4·3·2·1) |
| Mercenaries | 3 | 5 gold | Steal 3 of each resource |
| Cleanse | 3 | 5 gold | Remove fire from catapult |

### Defender Cards (Castle/AI)

| Card | Tier | Cost | Effect (tier-dependent damage) |
|------|------|------|-------------------------------|
| Archers | 1 | 3 food | Damage to catapult (4-6); 25% kill infantry |
| Balista | 2 | 5 stone + 5 gold | Heavy damage to catapult (9-14) |
| Boulders | 2 | 5 stone | Kill one infantry |
| Sabotage | 2 | 5 gold | Steal 3 of each resource |
| Fire Arrows | 3 | 5 food + 3 gold | Damage + catapult fire DoT; 50% kill infantry |
| Cleanse | 3 | 5 gold | Remove fire from wall |

## The AI

The defender AI scores every legal move in one currency: **race points** (1 point = 1 HP of progress toward winning). Difficulty is controlled by two parameters:

### Sight (1-5)

Controls which scoring terms the AI can see:

- **Sight 1**: Immediate damage only
- **Sight 2**: + Reactions (values killing infantry, removing fire)
- **Sight 3**: + Deferred damage (counts DoT ticks)
- **Sight 4**: + Race awareness (weighs prevention based on who's ahead)
- **Sight 5**: + Planning (holds for better plays next turn when safe)

### Noise (0-0.30)

Probability of fumbling to the 2nd-best move. Creates believable mistakes at lower difficulties.

### Race Estimation

The AI continuously tracks:
- `attackerDPS` and `defenderDPS` (damage per turn, derived from actual game progress)
- `turnsToLose` and `turnsToWin` (estimated turns until each player wins)
- `ahead` (boolean: is defender winning the race?)
- `preventMult` (0.6-1.5: how much to value prevention vs. offense)

This makes the AI reactive: it plays defensively when losing, aggressively when ahead.

## Difficulty Tiers

| # | Name | HP | Sight | Noise | Notes |
|---|------|-----|-------|-------|-------|
| 1 | The Outpost | 50 | 1 | 0.30 | Beginner-friendly warm-up |
| 2 | The Garrison | 55 | 2 | 0.20 | Learns to react to threats |
| 3 | The Keep | 60 | 3 | 0.10 | Understands DoT value |
| 4 | The Stronghold | 65 | 4 | 0.05 | Race-aware, strategic |
| 5 | The Fortress | 70 | 5 | 0.00 | Perfect play with planning |

Tested across ~40k simulated games: no stalemates, all games terminate in under 100 turns.

## Campaign

Linear progression: 5 nodes (one per tier). Win advances, lose retries. Beat The Fortress to be crowned king.

**No persistence in this milestone** — sessions start fresh at The Outpost. Persistence is future work.

## Running the App

```bash
# Ensure Flutter is available
export PATH="$HOME/flutter/bin:$PATH"

# Get dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Run on macOS desktop (if on macOS)
flutter run -d macos

# Or build for release
flutter build apk     # Android
flutter build ios     # iOS (requires macOS + Xcode)
flutter build macos   # macOS desktop (requires macOS)
```

**Platform support**: Android, iOS, and macOS desktop. The UI adapts to both tall phone screens (portrait) and shorter desktop windows via scrollable layouts.

The app opens to the campaign map. Tap "LAY SIEGE" to start a battle. During battle:
- Tap a card to play it (if you can afford the cost)
- Or use "DISCARD" to discard a card
- Either action ends your turn; the AI responds automatically
- Win by reducing the castle's wall to 0
- Lose if your catapult reaches 0
- Beat all 5 castles to be crowned king

## Running Tests

```bash
# Ensure Flutter is available
export PATH="$HOME/flutter/bin:$PATH"

# Run all tests (engine + simulation + campaign)
flutter test

# Run specific test suites
flutter test test/engine_test.dart
flutter test test/simulation_test.dart
flutter test test/campaign_test.dart

# Verbose output
flutter test --verbose
```

### Test Coverage

- **engine_test.dart**: Unit tests for core mechanics (cards, turns, DoT, win conditions, JSON serialization)
- **simulation_test.dart**: Simulation harness proving games terminate; runs 100+ automated battles
- **campaign_test.dart**: Campaign progression and state management

## Key Implementation Notes

### Porting from the Demo

The JavaScript demo (`siege-demo.html`) is the canonical reference for rules and AI behavior. This Dart implementation is a 1:1 port of:

- Card effects (exact damage values, DoT sequences)
- Turn sequence (income → persistent effects → play/discard → draw)
- AI scoring (`chooseDefender`, `defScore`, `computeRace`)
- Difficulty tiers (HP, sight, noise, defender damage configs)

### Infantry Mechanics

Infantry is the only persistent unit:
- Costs 5 food to deploy (max 2 active)
- Each player turn: pays 2 food upkeep, then deals 1 damage to wall
- Starves (removed) if upkeep can't be paid
- Defender can kill with Archers (25%), Fire Arrows (50%), or Boulders (100%)

**Known design issue** (per spec): Infantry is deliberately overpowered as food-only cost. This is a flagged "retune later" placeholder; the spec notes the likely fix is adding a small gold cost.

### Fire DoT (Damage over Time)

- Fireball creates gate fire: [4, 3, 2, 1] ticking on attacker turns
- Fire Arrows creates catapult fire: [3, 2, 1] or [4, 3, 2, 1] (tier 5) ticking on defender turns
- Each tick removes one value and deals that damage
- Cleanse immediately clears fire on the caster's own asset

### Deck & Reshuffle

- Deck composition: 3× tier-1 cards, 2× tier-2, 1× tier-3 (10 cards per side)
- When deck is empty and a draw is needed, shuffle discard pile into a new deck
- This guarantees infinite card availability (no stalemates from card exhaustion)

## Future Milestones (Out of Scope)

- **Flutter UI**: Battle screen, campaign map, animations
- **Multiplayer**: Hotseat, Bluetooth (same-OS), online (server-authoritative)
- **Meta layer**: Unlocks, loadouts, upgrades
- **Persistence**: Save/load campaign progress
- **Balance tuning**: Infantry rebalance, difficulty curve smoothing

## Architecture Benefits

This milestone establishes the foundation for all future work:

1. **UI layer** (next milestone) only renders `GameState` and emits `Move`s — no game logic
2. **Multiplayer** is just a different move source: opponent's moves arrive over Bluetooth/network and feed the same `applyMove`
3. **Replay/spectate** is trivial: store moves, replay through `applyMove`
4. **Save/load** is JSON serialization (already implemented)
5. **Headless testing** validates balance without UI (proven in this milestone's simulation harness)

## Milestones

### ✅ Milestone 1: Pure Dart Engine
- [x] Pure Dart engine with zero Flutter imports in `lib/engine/` and `lib/campaign/`
- [x] Complete card system (12 cards: 6 attacker, 6 defender)
- [x] Turn sequence with persistent effects (infantry, fire DoT)
- [x] Win/loss conditions
- [x] Deck composition and reshuffle
- [x] Defender AI with sight levels 1-5, noise, and planning
- [x] Difficulty tiers 1-5 with correct HP and AI parameters
- [x] Campaign progression (linear, no persistence)
- [x] Headless tests proving games terminate
- [x] JSON-serializable `GameState`
- [x] Analyzer clean, tests green

### ✅ Milestone 2: Flutter UI
- [x] Campaign map screen with 5 nodes (conquered/current/locked states)
- [x] Battle screen with health bars, resources, hand, log
- [x] Card interaction (tap to play, discard)
- [x] AI turn automation (AI responds after player acts)
- [x] Win/loss/crowned overlays
- [x] Navigation (map ↔ battle)
- [x] Dark medieval mobile-first theme
- [x] State management (ChangeNotifier)
- [x] Analyzer clean, all engine tests still pass

### 🚧 Future Work
- Multiplayer (hotseat, Bluetooth, online)
- Persistence (save/load campaign progress)
- Meta layer (unlocks, loadouts, upgrades)
- Balance tuning
- Sound & polish

## Running the Engine Headless

```dart
import 'package:castle_hero/engine/engine.dart';
import 'package:castle_hero/engine/ai.dart';
import 'package:castle_hero/campaign/tiers.dart';

void main() {
  // Create a battle at The Outpost
  final tier = tiers[0];
  var state = createInitialState(
    hp: tier.hp,
    defenderConfig: tier.defenderConfig,
    aiConfig: tier.aiConfig,
  );

  state = startPlayerTurn(state, firstTurn: true);

  // Game loop
  while (state.phase != Phase.over) {
    if (state.phase == Phase.player) {
      // Human would choose move here; for sim, just discard
      final move = DiscardAttackerCard(handIndex: 0);
      state = applyMove(state, move);
    } else if (state.phase == Phase.ai) {
      final move = chooseDefenderMove(state);
      state = applyMove(state, move);
    }
  }

  print('Game over! Attacker won: ${state.defender.wall <= 0}');
}
```

## UI Design Notes

The UI implements a **dark medieval mobile-first theme** inspired by the design brief:

- **Color palette**: Dark background (#12151b), warm attacker orange (#ef8b4a), cool defender blue (#6fa6c9), danger red, good green, gold accents
- **Typography**: Oswald for headers (uppercase, bold), Inter for body text
- **Layout**: Portrait-optimized for phones; all battle info visible at once
- **Focal point**: Health bars dominate the top of the battle screen (the depletion race is the hero)
- **Persistent effects**: Infantry and fire DoT shown as tags below health bars
- **Cards**: 3-card hand with tier dots (green/gold/orange), cost display, effect text
- **Battle log**: Recent 5 events scroll; newest at bottom
- **Overlays**: Centered modal for win/loss/crowned states

The demo HTML's CSS was **not** used as a visual reference — only its behavior and information architecture informed the Flutter implementation.
