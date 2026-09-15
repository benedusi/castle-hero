import 'package:flutter_test/flutter_test.dart';
import 'package:castle_hero/engine/cards.dart';
import 'package:castle_hero/engine/game_state.dart';
import 'package:castle_hero/engine/engine.dart';
import 'package:castle_hero/engine/move.dart';
import 'package:castle_hero/engine/ai.dart';
import 'package:castle_hero/campaign/tiers.dart';
import 'dart:math';

Move chooseRandomAttackerMove(GameState state) {
  final random = Random();
  final affordableIndices = <int>[];

  for (int i = 0; i < state.attacker.hand.length; i++) {
    final card = state.attacker.hand[i];
    final cost = attackerCards[card]!.cost;
    if (canAfford(
        state.attacker.stone, state.attacker.food, state.attacker.gold, cost)) {
      affordableIndices.add(i);
    }
  }

  if (affordableIndices.isNotEmpty && random.nextDouble() > 0.1) {
    final index = affordableIndices[random.nextInt(affordableIndices.length)];
    final card = state.attacker.hand[index];
    return PlayAttackerCard(card: card, handIndex: index);
  } else {
    final index = random.nextInt(state.attacker.hand.length);
    return DiscardAttackerCard(handIndex: index);
  }
}

class SimulationResult {
  final bool attackerWon;
  final int turns;
  final int wallRemaining;
  final int catapultRemaining;

  SimulationResult({
    required this.attackerWon,
    required this.turns,
    required this.wallRemaining,
    required this.catapultRemaining,
  });
}

SimulationResult simulateGame(Tier tier, {int maxTurns = 200}) {
  var state = createInitialState(
    hp: tier.hp,
    defenderConfig: tier.defenderConfig,
    aiConfig: tier.aiConfig,
  );

  state = startPlayerTurn(state, firstTurn: true);

  while (state.phase != Phase.over && state.turn < maxTurns) {
    if (state.phase == Phase.player) {
      final move = chooseRandomAttackerMove(state);
      state = applyMove(state, move);
    } else if (state.phase == Phase.ai) {
      final move = chooseDefenderMove(state);
      state = applyMove(state, move);
    }
  }

  return SimulationResult(
    attackerWon: state.defender.wall <= 0,
    turns: state.turn,
    wallRemaining: state.defender.wall,
    catapultRemaining: state.attacker.catapult,
  );
}

void main() {
  group('Simulation Tests', () {
    test('Single game terminates at Outpost', () {
      final tier = tiers[0];
      final result = simulateGame(tier);

      expect(result.turns, lessThan(200));
      expect(
          result.wallRemaining == 0 || result.catapultRemaining == 0, true);
    });

    test('Single game terminates at Fortress', () {
      final tier = tiers[4];
      final result = simulateGame(tier);

      expect(result.turns, lessThan(200));
      expect(
          result.wallRemaining == 0 || result.catapultRemaining == 0, true);
    });

    test('Multiple games at each tier terminate', () {
      for (final tier in tiers) {
        int wins = 0;
        int losses = 0;
        int totalTurns = 0;
        const gamesPerTier = 20;

        for (int i = 0; i < gamesPerTier; i++) {
          final result = simulateGame(tier);

          expect(result.turns, lessThan(200),
              reason: 'Game at ${tier.name} did not terminate');
          expect(
              result.wallRemaining == 0 || result.catapultRemaining == 0, true,
              reason: 'Game at ${tier.name} ended without a clear winner');

          if (result.attackerWon) {
            wins++;
          } else {
            losses++;
          }
          totalTurns += result.turns;
        }

        final avgTurns = totalTurns / gamesPerTier;

        // Log test results for debugging
        // ${tier.name}: ${wins}W/${losses}L (${(wins / gamesPerTier * 100).toStringAsFixed(1)}% win) avg ${avgTurns.toStringAsFixed(1)} turns

        expect(wins + losses, gamesPerTier);
        expect(avgTurns, greaterThan(5));
        expect(avgTurns, lessThan(100));
      }
    });

    test('No stalemates in 100 games', () {
      const totalGames = 100;
      int stalemates = 0;

      for (int i = 0; i < totalGames; i++) {
        final tier = tiers[Random().nextInt(tiers.length)];
        final result = simulateGame(tier, maxTurns: 200);

        if (result.turns >= 200) {
          stalemates++;
        }
      }

      expect(stalemates, 0,
          reason: 'Found $stalemates stalemates in $totalGames games');
    });

    test('AI-vs-AI produces reasonable game length', () {
      final tier = tiers[2];
      final List<int> gameLengths = [];

      for (int i = 0; i < 10; i++) {
        final result = simulateGame(tier);
        gameLengths.add(result.turns);
      }

      final avgLength = gameLengths.reduce((a, b) => a + b) / gameLengths.length;

      expect(avgLength, greaterThan(10));
      expect(avgLength, lessThan(80));
    });

    test('Games get longer at higher tiers', () {
      final outpostGames = <int>[];
      final fortressGames = <int>[];

      for (int i = 0; i < 10; i++) {
        final outpostResult = simulateGame(tiers[0]);
        final fortressResult = simulateGame(tiers[4]);

        outpostGames.add(outpostResult.turns);
        fortressGames.add(fortressResult.turns);
      }

      final avgOutpost =
          outpostGames.reduce((a, b) => a + b) / outpostGames.length;
      final avgFortress =
          fortressGames.reduce((a, b) => a + b) / fortressGames.length;

      // Log: Avg Outpost: $avgOutpost turns, Avg Fortress: $avgFortress turns

      expect(avgFortress, greaterThan(avgOutpost * 0.8));
    });
  });
}
