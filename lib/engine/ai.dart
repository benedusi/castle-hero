import 'dart:math';
import 'cards.dart';
import 'game_state.dart';
import 'move.dart';

class RaceInfo {
  final double attackerDPS;
  final double defenderDPS;
  final int turnsToLose;
  final int turnsToWin;
  final bool ahead;
  final double preventMult;
  final int battleLeft;

  RaceInfo({
    required this.attackerDPS,
    required this.defenderDPS,
    required this.turnsToLose,
    required this.turnsToWin,
    required this.ahead,
    required this.preventMult,
    required this.battleLeft,
  });
}

RaceInfo computeRace(GameState state) {
  final pDone = state.playerTurnsCompleted;
  final dDone = state.defenderTurnsCompleted;

  final attackerDPS = pDone >= 2
      ? max(1.5, (state.wallMax - state.defender.wall) / pDone)
      : 3.5;

  final defenderDPS = dDone >= 2
      ? max(1.5, (state.catapultMax - state.attacker.catapult) / dDone)
      : 3.5;

  final turnsToLose = max(1, (state.defender.wall / attackerDPS).ceil());
  final turnsToWin = max(1, (state.attacker.catapult / defenderDPS).ceil());

  final ahead = turnsToWin <= turnsToLose;
  final preventMult = (turnsToWin / turnsToLose).clamp(0.6, 1.5);
  final battleLeft = min(turnsToWin, turnsToLose);

  return RaceInfo(
    attackerDPS: attackerDPS,
    defenderDPS: defenderDPS,
    turnsToLose: turnsToLose,
    turnsToWin: turnsToWin,
    ahead: ahead,
    preventMult: preventMult,
    battleLeft: battleLeft,
  );
}

double infantryThreat(RaceInfo race) {
  return min(4.0, race.battleLeft.toDouble());
}

double sabotageValue(GameState state) {
  final a = state.attacker;
  final total = a.stone + a.food + a.gold;
  return ((18 - total) / 3).clamp(0, 5);
}

double scoreDefenderCard(
    GameState state, DefenderCard card, RaceInfo race) {
  final sight = state.aiConfig.sight;
  final react = sight >= 2;
  final deferred = sight >= 3;
  final prevent = sight >= 4 ? race.preventMult : 1.0;
  final dc = state.defenderConfig;

  switch (card) {
    case DefenderCard.balista:
      return dc.balista.toDouble();

    case DefenderCard.fireArrows:
      final dotSum = dc.fireArrowsDot.reduce((a, b) => a + b);
      final base = deferred ? dc.fireArrows + dotSum : dc.fireArrows.toDouble();
      final killBonus = (react && state.infantry > 0)
          ? 0.5 * infantryThreat(race) * prevent
          : 0.0;
      return base + killBonus;

    case DefenderCard.archers:
      final base = dc.archers.toDouble();
      final killBonus = (react && state.infantry > 0)
          ? 0.25 * infantryThreat(race) * prevent
          : 0.0;
      return base + killBonus;

    case DefenderCard.boulders:
      return (react && state.infantry > 0)
          ? infantryThreat(race) * prevent
          : 0.0;

    case DefenderCard.cleanse:
      if (!react) return 0.0;
      final fireSum =
          state.gateFire.isNotEmpty ? state.gateFire.reduce((a, b) => a + b) : 0;
      return fireSum * prevent;

    case DefenderCard.sabotage:
      return react ? sabotageValue(state) * prevent : 0.0;
  }
}

bool canAffordCard(DefenderState defender, DefenderCard card) {
  final cost = defenderCards[card]!.cost;
  return defender.stone >= cost.stone &&
      defender.food >= cost.food &&
      defender.gold >= cost.gold;
}

bool canAffordNext(DefenderState defender, DefenderCard card) {
  final cost = defenderCards[card]!.cost;
  final stoneDeficit = cost.stone - defender.stone;
  final foodDeficit = cost.food - defender.food;
  final goldDeficit = cost.gold - defender.gold;

  return stoneDeficit <= 1 && foodDeficit <= 1 && goldDeficit <= 1;
}

class ScoredCard {
  final DefenderCard card;
  final int handIndex;
  final double score;

  ScoredCard({
    required this.card,
    required this.handIndex,
    required this.score,
  });
}

int findLowestValueCard(
    GameState state, RaceInfo race, List<DefenderCard> hand,
    {DefenderCard? keep}) {
  double bestScore = double.infinity;
  int bestIndex = 0;

  for (int i = 0; i < hand.length; i++) {
    final card = hand[i];
    if (keep != null && card == keep) continue;

    final score = scoreDefenderCard(state, card, race);
    if (score < bestScore) {
      bestScore = score;
      bestIndex = i;
    }
  }

  return bestIndex;
}

Move chooseDefenderMove(GameState state) {
  final race = computeRace(state);
  final defender = state.defender;
  final hand = defender.hand;

  final affordableCards = <ScoredCard>[];

  for (int i = 0; i < hand.length; i++) {
    final card = hand[i];
    if (canAffordCard(defender, card)) {
      final score = scoreDefenderCard(state, card, race);
      affordableCards.add(ScoredCard(card: card, handIndex: i, score: score));
    }
  }

  affordableCards.sort((a, b) => b.score.compareTo(a.score));

  final best = affordableCards.isNotEmpty ? affordableCards[0] : null;

  if (state.aiConfig.sight >= 5 && race.ahead && race.turnsToLose > 2) {
    ScoredCard? holdCard;

    for (int i = 0; i < hand.length; i++) {
      final card = hand[i];
      final cost = defenderCards[card]!.cost;

      if (canAffordCard(defender, card)) continue;
      if (!canAffordNext(defender, card)) continue;

      final pv = scoreDefenderCard(state, card, race) * 0.9;
      if (best != null && pv <= best.score) continue;

      final afterStone = defender.stone;
      final afterFood = defender.food;
      final afterGold = defender.gold;

      if (best != null) {
        final bestCost = defenderCards[best.card]!.cost;
        final testStone = afterStone - bestCost.stone + 1;
        final testFood = afterFood - bestCost.food + 1;
        final testGold = afterGold - bestCost.gold + 1;

        final wouldBlock = testStone < cost.stone ||
            testFood < cost.food ||
            testGold < cost.gold;

        if (wouldBlock || best.score < 1) {
          if (holdCard == null || pv > holdCard.score) {
            holdCard = ScoredCard(card: card, handIndex: i, score: pv);
          }
        }
      } else {
        if (holdCard == null || pv > holdCard.score) {
          holdCard = ScoredCard(card: card, handIndex: i, score: pv);
        }
      }
    }

    if (holdCard != null && (best == null || holdCard.score > best.score)) {
      final discardIndex = findLowestValueCard(state, race, hand, keep: holdCard.card);
      return DiscardDefenderCard(handIndex: discardIndex);
    }
  }

  if (best != null &&
      best.score > 0 &&
      affordableCards.length >= 2 &&
      Random().nextDouble() < state.aiConfig.noise) {
    return PlayDefenderCard(
        card: affordableCards[1].card, handIndex: affordableCards[1].handIndex);
  }

  if (best != null && best.score > 0) {
    return PlayDefenderCard(card: best.card, handIndex: best.handIndex);
  }

  final discardIndex = findLowestValueCard(state, race, hand);
  return DiscardDefenderCard(handIndex: discardIndex);
}
