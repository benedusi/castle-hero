import 'package:flutter_test/flutter_test.dart';
import 'package:castle_hero/engine/cards.dart';
import 'package:castle_hero/engine/game_state.dart';
import 'package:castle_hero/engine/engine.dart';
import 'package:castle_hero/engine/move.dart';
import 'package:castle_hero/engine/ai.dart';
import 'package:castle_hero/campaign/tiers.dart';

void main() {
  group('Engine Tests', () {
    test('Initial state created correctly', () {
      final tier = tiers[0];
      final state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      expect(state.turn, 1);
      expect(state.phase, Phase.player);
      expect(state.attacker.stone, 5);
      expect(state.attacker.food, 5);
      expect(state.attacker.gold, 5);
      expect(state.defender.stone, 5);
      expect(state.defender.food, 5);
      expect(state.defender.gold, 5);
      expect(state.attacker.catapult, tier.hp);
      expect(state.defender.wall, tier.hp);
      expect(state.attacker.hand.length, 3);
      expect(state.defender.hand.length, 3);
      expect(state.infantry, 0);
      expect(state.gateFire, isEmpty);
      expect(state.catapultFire, isEmpty);
    });

    test('Resources capped at 25', () {
      expect(clampResource(30), 25);
      expect(clampResource(25), 25);
      expect(clampResource(20), 20);
      expect(clampResource(0), 0);
      expect(clampResource(-5), 0);
    });

    test('Can afford card', () {
      expect(canAfford(5, 5, 5, CardCost(stone: 3)), true);
      expect(canAfford(5, 5, 5, CardCost(stone: 6)), false);
      expect(canAfford(5, 5, 5, CardCost(stone: 3, gold: 5)), true);
      expect(canAfford(5, 5, 5, CardCost(stone: 3, gold: 6)), false);
    });

    test('Steal resources', () {
      final result = stealResources(
        fromStone: 10,
        fromFood: 10,
        fromGold: 10,
        toStone: 5,
        toFood: 5,
        toGold: 5,
        amount: 3,
      );

      expect(result.stolenStone, 3);
      expect(result.stolenFood, 3);
      expect(result.stolenGold, 3);
      expect(result.fromStone, 7);
      expect(result.fromFood, 7);
      expect(result.fromGold, 7);
      expect(result.toStone, 8);
      expect(result.toFood, 8);
      expect(result.toGold, 8);
    });

    test('Steal resources respects cap', () {
      final result = stealResources(
        fromStone: 10,
        fromFood: 10,
        fromGold: 10,
        toStone: 24,
        toFood: 24,
        toGold: 24,
        amount: 3,
      );

      expect(result.toStone, 25);
      expect(result.toFood, 25);
      expect(result.toGold, 25);
    });

    test('Draw cards works', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      final attacker = state.attacker.copyWith(hand: []);
      state = state.copyWith(attacker: attacker);

      final updatedAttacker = drawCards(state.attacker);
      expect(updatedAttacker.hand.length, 3);
    });

    test('Draw cards reshuffles when deck empty', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      final attacker = state.attacker.copyWith(
        deck: [],
        hand: [],
        discard: [AttackerCard.fire, AttackerCard.volley, AttackerCard.infantry],
      );

      final updatedAttacker = drawCards(attacker);
      expect(updatedAttacker.hand.length, 3);
      expect(updatedAttacker.deck.length, 0);
      expect(updatedAttacker.discard.length, 0);
    });

    test('Play attacker card - FIRE', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        attacker: state.attacker.copyWith(
          hand: [AttackerCard.fire, AttackerCard.volley, AttackerCard.infantry],
          stone: 10,
        ),
      );

      final initialWall = state.defender.wall;
      final move = PlayAttackerCard(card: AttackerCard.fire, handIndex: 0);
      state = applyMove(state, move);

      expect(state.defender.wall, initialWall - 5);
    });

    test('Play attacker card - INFANTRY', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        attacker: state.attacker.copyWith(
          hand: [
            AttackerCard.infantry,
            AttackerCard.volley,
            AttackerCard.fire
          ],
          food: 10,
        ),
      );

      final move = PlayAttackerCard(card: AttackerCard.infantry, handIndex: 0);
      state = applyMove(state, move);

      expect(state.infantry, 1);
    });

    test('Infantry deals damage and consumes food', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        infantry: 1,
        attacker: state.attacker.copyWith(food: 10),
      );

      final initialWall = state.defender.wall;
      final initialFood = state.attacker.food;
      state = startPlayerTurn(state);

      expect(state.defender.wall, initialWall - 1);
      expect(state.attacker.food, initialFood + 1 - 2);
    });

    test('Infantry starves without food', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        infantry: 2,
        attacker: state.attacker.copyWith(food: 1),
      );

      state = startPlayerTurn(state);

      expect(state.infantry, 1);
    });

    test('Fireball sets gate on fire', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        attacker: state.attacker.copyWith(
          hand: [
            AttackerCard.fireball,
            AttackerCard.volley,
            AttackerCard.fire
          ],
          stone: 10,
          gold: 10,
        ),
      );

      final initialWall = state.defender.wall;
      final move =
          PlayAttackerCard(card: AttackerCard.fireball, handIndex: 0);
      state = applyMove(state, move);

      expect(state.defender.wall, initialWall - 5);
      expect(state.gateFire, [4, 3, 2, 1]);
    });

    test('Gate fire ticks each player turn', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(gateFire: [4, 3, 2, 1]);

      final initialWall = state.defender.wall;
      state = startPlayerTurn(state);

      expect(state.defender.wall, initialWall - 4);
      expect(state.gateFire, [3, 2, 1]);
    });

    test('Win condition - wall destroyed', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        defender: state.defender.copyWith(wall: 5),
        attacker: state.attacker.copyWith(
          hand: [AttackerCard.fire, AttackerCard.volley, AttackerCard.infantry],
          stone: 10,
        ),
      );

      final move = PlayAttackerCard(card: AttackerCard.fire, handIndex: 0);
      state = applyMove(state, move);

      expect(state.defender.wall, 0);
      expect(state.phase, Phase.over);
    });

    test('Win condition - catapult destroyed', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        phase: Phase.ai,
        attacker: state.attacker.copyWith(catapult: 5),
        defender: state.defender.copyWith(
          hand: [
            DefenderCard.archers,
            DefenderCard.balista,
            DefenderCard.boulders
          ],
          food: 10,
        ),
      );

      final move = PlayDefenderCard(card: DefenderCard.archers, handIndex: 0);
      state = applyMove(state, move);

      expect(state.attacker.catapult, 1);

      state = state.copyWith(
        phase: Phase.ai,
        defender: state.defender.copyWith(
          hand: [
            DefenderCard.archers,
            DefenderCard.balista,
            DefenderCard.boulders
          ],
          food: 10,
        ),
      );

      final move2 = PlayDefenderCard(card: DefenderCard.archers, handIndex: 0);
      state = applyMove(state, move2);

      expect(state.attacker.catapult, 0);
      expect(state.phase, Phase.over);
    });

    test('Discard move', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      final handBefore = List.from(state.attacker.hand);
      final move = DiscardAttackerCard(handIndex: 0);
      state = applyMove(state, move);

      expect(state.attacker.hand.length, 3);
      expect(state.attacker.discard.last, handBefore[0]);
    });

    test('JSON serialization round-trip', () {
      final tier = tiers[0];
      final state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.turn, state.turn);
      expect(restored.phase, state.phase);
      expect(restored.attacker.stone, state.attacker.stone);
      expect(restored.defender.wall, state.defender.wall);
      expect(restored.infantry, state.infantry);
    });
  });

  group('AI Tests', () {
    test('Race computation', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        playerTurnsCompleted: 5,
        defenderTurnsCompleted: 5,
        defender: state.defender.copyWith(wall: 40),
        attacker: state.attacker.copyWith(catapult: 45),
      );

      final race = computeRace(state);

      expect(race.attackerDPS, greaterThan(0));
      expect(race.defenderDPS, greaterThan(0));
      expect(race.turnsToLose, greaterThan(0));
      expect(race.turnsToWin, greaterThan(0));
    });

    test('AI chooses a move', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        phase: Phase.ai,
        defender: state.defender.copyWith(
          hand: [
            DefenderCard.archers,
            DefenderCard.balista,
            DefenderCard.boulders
          ],
          food: 10,
          stone: 10,
          gold: 10,
        ),
      );

      final move = chooseDefenderMove(state);
      expect(move, isNotNull);
      expect(move is PlayDefenderCard || move is DiscardDefenderCard, true);
    });

    test('AI scores balista highest without sight', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        phase: Phase.ai,
        defender: state.defender.copyWith(
          hand: [
            DefenderCard.balista,
            DefenderCard.archers,
            DefenderCard.boulders
          ],
          food: 10,
          stone: 10,
          gold: 10,
        ),
      );

      final race = computeRace(state);
      final balistaScore =
          scoreDefenderCard(state, DefenderCard.balista, race);
      final archersScore =
          scoreDefenderCard(state, DefenderCard.archers, race);

      expect(balistaScore, greaterThan(archersScore));
    });

    test('AI values boulders when infantry present and sight >= 2', () {
      final tier = tiers[1];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        phase: Phase.ai,
        infantry: 2,
        playerTurnsCompleted: 3,
        defenderTurnsCompleted: 3,
      );

      final race = computeRace(state);
      final bouldersScore =
          scoreDefenderCard(state, DefenderCard.boulders, race);

      expect(bouldersScore, greaterThan(0));
    });

    test('AI does not value boulders without infantry', () {
      final tier = tiers[0];
      var state = createInitialState(
        hp: tier.hp,
        defenderConfig: tier.defenderConfig,
        aiConfig: tier.aiConfig,
      );

      state = state.copyWith(
        phase: Phase.ai,
        infantry: 0,
      );

      final race = computeRace(state);
      final bouldersScore =
          scoreDefenderCard(state, DefenderCard.boulders, race);

      expect(bouldersScore, 0);
    });
  });
}
