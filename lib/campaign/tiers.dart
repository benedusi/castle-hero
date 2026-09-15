import '../engine/game_state.dart';

class Tier {
  final int level;
  final String name;
  final int hp;
  final AIConfig aiConfig;
  final DefenderConfig defenderConfig;

  const Tier({
    required this.level,
    required this.name,
    required this.hp,
    required this.aiConfig,
    required this.defenderConfig,
  });
}

const List<Tier> tiers = [
  Tier(
    level: 1,
    name: 'The Outpost',
    hp: 50,
    aiConfig: AIConfig(sight: 1, noise: 0.30),
    defenderConfig: DefenderConfig(
      archers: 4,
      balista: 9,
      fireArrows: 5,
      fireArrowsDot: [3, 2, 1],
    ),
  ),
  Tier(
    level: 2,
    name: 'The Garrison',
    hp: 55,
    aiConfig: AIConfig(sight: 2, noise: 0.20),
    defenderConfig: DefenderConfig(
      archers: 5,
      balista: 11,
      fireArrows: 5,
      fireArrowsDot: [3, 2, 1],
    ),
  ),
  Tier(
    level: 3,
    name: 'The Keep',
    hp: 60,
    aiConfig: AIConfig(sight: 3, noise: 0.10),
    defenderConfig: DefenderConfig(
      archers: 5,
      balista: 11,
      fireArrows: 5,
      fireArrowsDot: [3, 2, 1],
    ),
  ),
  Tier(
    level: 4,
    name: 'The Stronghold',
    hp: 65,
    aiConfig: AIConfig(sight: 4, noise: 0.05),
    defenderConfig: DefenderConfig(
      archers: 5,
      balista: 13,
      fireArrows: 5,
      fireArrowsDot: [3, 2, 1],
    ),
  ),
  Tier(
    level: 5,
    name: 'The Fortress',
    hp: 70,
    aiConfig: AIConfig(sight: 5, noise: 0.00),
    defenderConfig: DefenderConfig(
      archers: 6,
      balista: 14,
      fireArrows: 7,
      fireArrowsDot: [4, 3, 2, 1],
    ),
  ),
];
