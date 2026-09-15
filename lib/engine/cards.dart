enum AttackerCard {
  fire,
  volley,
  infantry,
  fireball,
  mercenaries,
  cleanse,
}

enum DefenderCard {
  archers,
  balista,
  boulders,
  sabotage,
  fireArrows,
  cleanse,
}

class CardCost {
  final int stone;
  final int food;
  final int gold;

  const CardCost({this.stone = 0, this.food = 0, this.gold = 0});

  Map<String, dynamic> toJson() => {
        'stone': stone,
        'food': food,
        'gold': gold,
      };

  factory CardCost.fromJson(Map<String, dynamic> json) => CardCost(
        stone: json['stone'] as int? ?? 0,
        food: json['food'] as int? ?? 0,
        gold: json['gold'] as int? ?? 0,
      );
}

class AttackerCardDef {
  final AttackerCard card;
  final String name;
  final int tier;
  final CardCost cost;
  final String desc;

  const AttackerCardDef({
    required this.card,
    required this.name,
    required this.tier,
    required this.cost,
    required this.desc,
  });
}

class DefenderCardDef {
  final DefenderCard card;
  final String name;
  final int tier;
  final CardCost cost;

  const DefenderCardDef({
    required this.card,
    required this.name,
    required this.tier,
    required this.cost,
  });
}

const Map<AttackerCard, AttackerCardDef> attackerCards = {
  AttackerCard.fire: AttackerCardDef(
    card: AttackerCard.fire,
    name: 'Fire',
    tier: 1,
    cost: CardCost(stone: 3),
    desc: '5 damage to the wall.',
  ),
  AttackerCard.volley: AttackerCardDef(
    card: AttackerCard.volley,
    name: 'Volley',
    tier: 2,
    cost: CardCost(stone: 6),
    desc: '12 damage to the wall.',
  ),
  AttackerCard.infantry: AttackerCardDef(
    card: AttackerCard.infantry,
    name: 'Infantry',
    tier: 2,
    cost: CardCost(food: 5),
    desc:
        'Deploy soldiers. Each day: eat 2 food, deal 1 to the wall. Max 2. Starve if unfed; the castle can kill them.',
  ),
  AttackerCard.fireball: AttackerCardDef(
    card: AttackerCard.fireball,
    name: 'Fireball',
    tier: 3,
    cost: CardCost(stone: 3, gold: 5),
    desc: '5 damage now, then sets the gate ablaze: 4·3·2·1 over your next days.',
  ),
  AttackerCard.mercenaries: AttackerCardDef(
    card: AttackerCard.mercenaries,
    name: 'Mercenaries',
    tier: 3,
    cost: CardCost(gold: 5),
    desc: 'Steal 3 of each resource from the castle.',
  ),
  AttackerCard.cleanse: AttackerCardDef(
    card: AttackerCard.cleanse,
    name: 'Cleanse',
    tier: 3,
    cost: CardCost(gold: 5),
    desc: 'Put out the fire on your catapult.',
  ),
};

const Map<DefenderCard, DefenderCardDef> defenderCards = {
  DefenderCard.archers: DefenderCardDef(
    card: DefenderCard.archers,
    name: 'Archers',
    tier: 1,
    cost: CardCost(food: 3),
  ),
  DefenderCard.balista: DefenderCardDef(
    card: DefenderCard.balista,
    name: 'Balista',
    tier: 2,
    cost: CardCost(stone: 5, gold: 5),
  ),
  DefenderCard.boulders: DefenderCardDef(
    card: DefenderCard.boulders,
    name: 'Boulders',
    tier: 2,
    cost: CardCost(stone: 5),
  ),
  DefenderCard.sabotage: DefenderCardDef(
    card: DefenderCard.sabotage,
    name: 'Sabotage',
    tier: 2,
    cost: CardCost(gold: 5),
  ),
  DefenderCard.fireArrows: DefenderCardDef(
    card: DefenderCard.fireArrows,
    name: 'Fire Arrows',
    tier: 3,
    cost: CardCost(food: 5, gold: 3),
  ),
  DefenderCard.cleanse: DefenderCardDef(
    card: DefenderCard.cleanse,
    name: 'Cleanse',
    tier: 3,
    cost: CardCost(gold: 5),
  ),
};

List<AttackerCard> buildAttackerDeck() {
  final List<AttackerCard> deck = [];
  for (final entry in attackerCards.entries) {
    final count = entry.value.tier == 1
        ? 3
        : entry.value.tier == 2
            ? 2
            : 1;
    for (int i = 0; i < count; i++) {
      deck.add(entry.key);
    }
  }
  deck.shuffle();
  return deck;
}

List<DefenderCard> buildDefenderDeck() {
  final List<DefenderCard> deck = [];
  for (final entry in defenderCards.entries) {
    final count = entry.value.tier == 1
        ? 3
        : entry.value.tier == 2
            ? 2
            : 1;
    for (int i = 0; i < count; i++) {
      deck.add(entry.key);
    }
  }
  deck.shuffle();
  return deck;
}
