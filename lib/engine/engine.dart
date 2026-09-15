import 'dart:math';
import 'cards.dart';
import 'game_state.dart';
import 'move.dart';

const int resourceCap = 25;
const int handSize = 3;

GameState createInitialState({
  required int hp,
  required DefenderConfig defenderConfig,
  required AIConfig aiConfig,
}) {
  final attackerDeck = buildAttackerDeck();
  final defenderDeck = buildDefenderDeck();

  final attackerHand = <AttackerCard>[];
  final defenderHand = <DefenderCard>[];

  for (int i = 0; i < handSize; i++) {
    if (attackerDeck.isNotEmpty) attackerHand.add(attackerDeck.removeLast());
    if (defenderDeck.isNotEmpty) defenderHand.add(defenderDeck.removeLast());
  }

  return GameState(
    turn: 1,
    phase: Phase.player,
    wallMax: hp,
    catapultMax: hp,
    attacker: PlayerState(
      stone: 5,
      food: 5,
      gold: 5,
      deck: attackerDeck,
      hand: attackerHand,
      discard: [],
      catapult: hp,
    ),
    defender: DefenderState(
      stone: 5,
      food: 5,
      gold: 5,
      deck: defenderDeck,
      hand: defenderHand,
      discard: [],
      wall: hp,
    ),
    defenderConfig: defenderConfig,
    aiConfig: aiConfig,
    infantry: 0,
    gateFire: [],
    catapultFire: [],
    log: [],
    playerTurnsCompleted: 0,
    defenderTurnsCompleted: 0,
    discardMode: false,
  );
}

int clampResource(int value) => value.clamp(0, resourceCap);

bool canAfford(int stone, int food, int gold, CardCost cost) {
  return stone >= cost.stone && food >= cost.food && gold >= cost.gold;
}

void payCost(
    {required int stone,
    required int food,
    required int gold,
    required CardCost cost,
    required void Function(int, int, int) onPaid}) {
  onPaid(stone - cost.stone, food - cost.food, gold - cost.gold);
}

class StealResult {
  final int stolenStone;
  final int stolenFood;
  final int stolenGold;
  final int fromStone;
  final int fromFood;
  final int fromGold;
  final int toStone;
  final int toFood;
  final int toGold;

  StealResult({
    required this.stolenStone,
    required this.stolenFood,
    required this.stolenGold,
    required this.fromStone,
    required this.fromFood,
    required this.fromGold,
    required this.toStone,
    required this.toFood,
    required this.toGold,
  });
}

StealResult stealResources({
  required int fromStone,
  required int fromFood,
  required int fromGold,
  required int toStone,
  required int toFood,
  required int toGold,
  required int amount,
}) {
  final stolenStone = min(amount, fromStone);
  final stolenFood = min(amount, fromFood);
  final stolenGold = min(amount, fromGold);

  return StealResult(
    stolenStone: stolenStone,
    stolenFood: stolenFood,
    stolenGold: stolenGold,
    fromStone: fromStone - stolenStone,
    fromFood: fromFood - stolenFood,
    fromGold: fromGold - stolenGold,
    toStone: clampResource(toStone + stolenStone),
    toFood: clampResource(toFood + stolenFood),
    toGold: clampResource(toGold + stolenGold),
  );
}

PlayerState drawCards(PlayerState player) {
  var deck = List<AttackerCard>.from(player.deck);
  var hand = List<AttackerCard>.from(player.hand);
  var discard = List<AttackerCard>.from(player.discard);

  while (hand.length < handSize) {
    if (deck.isEmpty) {
      if (discard.isEmpty) break;
      deck = List<AttackerCard>.from(discard);
      deck.shuffle();
      discard = [];
    }
    hand.add(deck.removeLast());
  }

  return player.copyWith(deck: deck, hand: hand, discard: discard);
}

DefenderState drawCardsDefender(DefenderState defender) {
  var deck = List<DefenderCard>.from(defender.deck);
  var hand = List<DefenderCard>.from(defender.hand);
  var discard = List<DefenderCard>.from(defender.discard);

  while (hand.length < handSize) {
    if (deck.isEmpty) {
      if (discard.isEmpty) break;
      deck = List<DefenderCard>.from(discard);
      deck.shuffle();
      discard = [];
    }
    hand.add(deck.removeLast());
  }

  return defender.copyWith(deck: deck, hand: hand, discard: discard);
}

GameState addLog(GameState state, String message) {
  final log = List<String>.from(state.log);
  log.add(message);
  if (log.length > 40) log.removeAt(0);
  return state.copyWith(log: log);
}

GameState applyAttackerCard(GameState state, AttackerCard card) {
  var defender = state.defender;
  var attacker = state.attacker;
  var infantry = state.infantry;
  var gateFire = List<int>.from(state.gateFire);
  var catapultFire = List<int>.from(state.catapultFire);
  var updatedState = state;

  switch (card) {
    case AttackerCard.fire:
      defender = defender.copyWith(wall: defender.wall - 5);
      updatedState =
          addLog(state, 'You loose a boulder — 5 damage to the wall.');
      break;

    case AttackerCard.volley:
      defender = defender.copyWith(wall: defender.wall - 12);
      updatedState = addLog(state, 'You volley the walls — 12 damage.');
      break;

    case AttackerCard.infantry:
      infantry = min(infantry + 1, 2);
      updatedState =
          addLog(state, 'You send in infantry. They advance on the gate.');
      break;

    case AttackerCard.fireball:
      defender = defender.copyWith(wall: defender.wall - 5);
      gateFire = [4, 3, 2, 1];
      updatedState = addLog(
          state, 'You hurl a fireball — 5 damage, and the gate catches fire.');
      break;

    case AttackerCard.mercenaries:
      final result = stealResources(
        fromStone: defender.stone,
        fromFood: defender.food,
        fromGold: defender.gold,
        toStone: attacker.stone,
        toFood: attacker.food,
        toGold: attacker.gold,
        amount: 3,
      );
      defender = defender.copyWith(
        stone: result.fromStone,
        food: result.fromFood,
        gold: result.fromGold,
      );
      attacker = attacker.copyWith(
        stone: result.toStone,
        food: result.toFood,
        gold: result.toGold,
      );
      updatedState = addLog(state,
          'You mercenaries pillage the stores (+${result.stolenStone} stone, +${result.stolenFood} food, +${result.stolenGold} gold).');
      break;

    case AttackerCard.cleanse:
      catapultFire = [];
      updatedState =
          addLog(state, 'You douse the flames on your catapult.');
      break;
  }

  return updatedState.copyWith(
    defender: defender,
    attacker: attacker,
    infantry: infantry,
    gateFire: gateFire,
    catapultFire: catapultFire,
  );
}

GameState applyDefenderCard(GameState state, DefenderCard card) {
  var defender = state.defender;
  var attacker = state.attacker;
  var infantry = state.infantry;
  var gateFire = List<int>.from(state.gateFire);
  var catapultFire = List<int>.from(state.catapultFire);
  var updatedState = state;
  final dc = state.defenderConfig;
  final random = Random();

  switch (card) {
    case DefenderCard.archers:
      attacker = attacker.copyWith(catapult: attacker.catapult - dc.archers);
      bool killed = false;
      if (infantry > 0 && random.nextDouble() < 0.25) {
        infantry--;
        killed = true;
      }
      updatedState = addLog(
          state,
          'The castle loose archers — ${dc.archers} damage${killed ? '; an infantry unit falls' : ''}.');
      break;

    case DefenderCard.balista:
      attacker = attacker.copyWith(catapult: attacker.catapult - dc.balista);
      updatedState = addLog(
          state, 'The castle fire the balista — ${dc.balista} damage to your catapult.');
      break;

    case DefenderCard.boulders:
      if (infantry > 0) {
        infantry--;
        updatedState = addLog(
            state, 'The castle drop boulders — an infantry unit is crushed.');
      } else {
        updatedState = addLog(state,
            'The castle drop boulders — but no infantry to hit.');
      }
      break;

    case DefenderCard.sabotage:
      final result = stealResources(
        fromStone: attacker.stone,
        fromFood: attacker.food,
        fromGold: attacker.gold,
        toStone: defender.stone,
        toFood: defender.food,
        toGold: defender.gold,
        amount: 3,
      );
      attacker = attacker.copyWith(
        stone: result.fromStone,
        food: result.fromFood,
        gold: result.fromGold,
      );
      defender = defender.copyWith(
        stone: result.toStone,
        food: result.toFood,
        gold: result.toGold,
      );
      updatedState = addLog(
          state, 'The castle sabotage your camp — 3 of each resource stolen.');
      break;

    case DefenderCard.fireArrows:
      attacker =
          attacker.copyWith(catapult: attacker.catapult - dc.fireArrows);
      catapultFire = List<int>.from(dc.fireArrowsDot);
      bool killed = false;
      if (infantry > 0 && random.nextDouble() < 0.5) {
        infantry--;
        killed = true;
      }
      updatedState = addLog(
          state,
          'The castle rain fire arrows — ${dc.fireArrows} damage, and your catapult ignites${killed ? '; an infantry unit falls' : ''}.');
      break;

    case DefenderCard.cleanse:
      gateFire = [];
      updatedState =
          addLog(state, 'The castle smother the fire on the gate.');
      break;
  }

  return updatedState.copyWith(
    defender: defender,
    attacker: attacker,
    infantry: infantry,
    gateFire: gateFire,
    catapultFire: catapultFire,
  );
}

GameState? checkWin(GameState state) {
  if (state.defender.wall <= 0) {
    return state.copyWith(
      defender: state.defender.copyWith(wall: 0),
      phase: Phase.over,
    );
  }
  if (state.attacker.catapult <= 0) {
    return state.copyWith(
      attacker: state.attacker.copyWith(catapult: 0),
      phase: Phase.over,
    );
  }
  return null;
}

GameState startPlayerTurn(GameState state, {bool firstTurn = false}) {
  var attacker = state.attacker;
  var defender = state.defender;
  var infantry = state.infantry;
  var gateFire = List<int>.from(state.gateFire);
  var catapultFire = List<int>.from(state.catapultFire);
  var updatedState = state;

  attacker = attacker.copyWith(
    stone: clampResource(attacker.stone + 1),
    food: clampResource(attacker.food + 1),
    gold: clampResource(attacker.gold + 1),
  );

  if (!firstTurn) {
    updatedState = addLog(
        state, 'Day ${state.turn} — you gather +1 of each resource.');
  }

  if (gateFire.isNotEmpty) {
    final damage = gateFire.removeAt(0);
    defender = defender.copyWith(wall: defender.wall - damage);
    updatedState = addLog(updatedState, 'You — gate burns for $damage damage.');
  }

  if (infantry > 0) {
    int alive = 0;
    int hits = 0;
    final beforeInf = infantry;

    for (int i = 0; i < beforeInf; i++) {
      if (attacker.food >= 2) {
        attacker = attacker.copyWith(food: attacker.food - 2);
        defender = defender.copyWith(wall: defender.wall - 1);
        hits++;
        alive++;
      }
    }

    infantry = alive;

    if (hits > 0) {
      updatedState = addLog(updatedState,
          'You — infantry batter the gate for $hits damage (ate ${hits * 2} food).');
    }

    if (alive < beforeInf) {
      updatedState = addLog(updatedState,
          'System: ${beforeInf - alive} infantry unit(s) starved and dispersed.');
    }
  }

  final winState = checkWin(updatedState.copyWith(
    attacker: attacker,
    defender: defender,
    infantry: infantry,
    gateFire: gateFire,
    catapultFire: catapultFire,
  ));

  if (winState != null) return winState;

  return updatedState.copyWith(
    attacker: attacker,
    defender: defender,
    infantry: infantry,
    gateFire: gateFire,
    catapultFire: catapultFire,
    phase: Phase.player,
  );
}

GameState startDefenderTurn(GameState state) {
  var attacker = state.attacker;
  var defender = state.defender;
  var catapultFire = List<int>.from(state.catapultFire);
  var updatedState = state;

  defender = defender.copyWith(
    stone: clampResource(defender.stone + 1),
    food: clampResource(defender.food + 1),
    gold: clampResource(defender.gold + 1),
  );

  if (catapultFire.isNotEmpty) {
    final damage = catapultFire.removeAt(0);
    attacker = attacker.copyWith(catapult: attacker.catapult - damage);
    updatedState = addLog(
        state, 'The castle — your catapult burns for $damage damage.');
  }

  final winState = checkWin(updatedState.copyWith(
    attacker: attacker,
    defender: defender,
    catapultFire: catapultFire,
  ));

  if (winState != null) return winState;

  return updatedState.copyWith(
    attacker: attacker,
    defender: defender,
    catapultFire: catapultFire,
    phase: Phase.ai,
  );
}

GameState applyMove(GameState state, Move move) {
  if (move is PlayAttackerCard) {
    if (state.phase != Phase.player) return state;

    final card = state.attacker.hand[move.handIndex];
    final cost = attackerCards[card]!.cost;

    if (!canAfford(
        state.attacker.stone, state.attacker.food, state.attacker.gold, cost)) {
      return state;
    }

    var attacker = state.attacker.copyWith(
      stone: state.attacker.stone - cost.stone,
      food: state.attacker.food - cost.food,
      gold: state.attacker.gold - cost.gold,
    );

    final hand = List<AttackerCard>.from(attacker.hand);
    hand.removeAt(move.handIndex);
    final discard = List<AttackerCard>.from(attacker.discard);
    discard.add(card);
    attacker = attacker.copyWith(hand: hand, discard: discard);

    var updatedState = state.copyWith(attacker: attacker);
    updatedState = applyAttackerCard(updatedState, card);

    final winState = checkWin(updatedState);
    if (winState != null) return winState;

    attacker = drawCards(updatedState.attacker);
    updatedState = updatedState.copyWith(
      attacker: attacker,
      playerTurnsCompleted: state.playerTurnsCompleted + 1,
    );

    updatedState = startDefenderTurn(updatedState);
    return updatedState;
  } else if (move is DiscardAttackerCard) {
    if (state.phase != Phase.player) return state;

    final hand = List<AttackerCard>.from(state.attacker.hand);
    final card = hand.removeAt(move.handIndex);
    final discard = List<AttackerCard>.from(state.attacker.discard);
    discard.add(card);

    var attacker = state.attacker.copyWith(hand: hand, discard: discard);
    attacker = drawCards(attacker);

    var updatedState =
        addLog(state, 'You discard ${attackerCards[card]!.name}.');
    updatedState = updatedState.copyWith(
      attacker: attacker,
      playerTurnsCompleted: state.playerTurnsCompleted + 1,
    );

    updatedState = startDefenderTurn(updatedState);
    return updatedState;
  } else if (move is PlayDefenderCard) {
    if (state.phase != Phase.ai) return state;

    final card = state.defender.hand[move.handIndex];
    final cost = defenderCards[card]!.cost;

    if (!canAfford(
        state.defender.stone, state.defender.food, state.defender.gold, cost)) {
      return state;
    }

    var defender = state.defender.copyWith(
      stone: state.defender.stone - cost.stone,
      food: state.defender.food - cost.food,
      gold: state.defender.gold - cost.gold,
    );

    final hand = List<DefenderCard>.from(defender.hand);
    hand.removeAt(move.handIndex);
    final discard = List<DefenderCard>.from(defender.discard);
    discard.add(card);
    defender = defender.copyWith(hand: hand, discard: discard);

    var updatedState = state.copyWith(defender: defender);
    updatedState = applyDefenderCard(updatedState, card);

    final winState = checkWin(updatedState);
    if (winState != null) return winState;

    defender = drawCardsDefender(updatedState.defender);
    updatedState = updatedState.copyWith(
      defender: defender,
      defenderTurnsCompleted: state.defenderTurnsCompleted + 1,
      turn: state.turn + 1,
    );

    updatedState = startPlayerTurn(updatedState);
    return updatedState;
  } else if (move is DiscardDefenderCard) {
    if (state.phase != Phase.ai) return state;

    final hand = List<DefenderCard>.from(state.defender.hand);
    final card = hand.removeAt(move.handIndex);
    final discard = List<DefenderCard>.from(state.defender.discard);
    discard.add(card);

    var defender = state.defender.copyWith(hand: hand, discard: discard);
    defender = drawCardsDefender(defender);

    var updatedState =
        addLog(state, 'The castle wait and watch, discarding a card.');
    updatedState = updatedState.copyWith(
      defender: defender,
      defenderTurnsCompleted: state.defenderTurnsCompleted + 1,
      turn: state.turn + 1,
    );

    updatedState = startPlayerTurn(updatedState);
    return updatedState;
  }

  return state;
}
