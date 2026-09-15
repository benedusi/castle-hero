import 'cards.dart';

enum Phase {
  player,
  ai,
  over,
}

class PlayerState {
  final int stone;
  final int food;
  final int gold;
  final List<AttackerCard> deck;
  final List<AttackerCard> hand;
  final List<AttackerCard> discard;
  final int catapult;

  const PlayerState({
    required this.stone,
    required this.food,
    required this.gold,
    required this.deck,
    required this.hand,
    required this.discard,
    required this.catapult,
  });

  Map<String, dynamic> toJson() => {
        'stone': stone,
        'food': food,
        'gold': gold,
        'deck': deck.map((c) => c.name).toList(),
        'hand': hand.map((c) => c.name).toList(),
        'discard': discard.map((c) => c.name).toList(),
        'catapult': catapult,
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        stone: json['stone'] as int,
        food: json['food'] as int,
        gold: json['gold'] as int,
        deck: (json['deck'] as List)
            .map((s) => AttackerCard.values.byName(s as String))
            .toList(),
        hand: (json['hand'] as List)
            .map((s) => AttackerCard.values.byName(s as String))
            .toList(),
        discard: (json['discard'] as List)
            .map((s) => AttackerCard.values.byName(s as String))
            .toList(),
        catapult: json['catapult'] as int,
      );

  PlayerState copyWith({
    int? stone,
    int? food,
    int? gold,
    List<AttackerCard>? deck,
    List<AttackerCard>? hand,
    List<AttackerCard>? discard,
    int? catapult,
  }) =>
      PlayerState(
        stone: stone ?? this.stone,
        food: food ?? this.food,
        gold: gold ?? this.gold,
        deck: deck ?? List.from(this.deck),
        hand: hand ?? List.from(this.hand),
        discard: discard ?? List.from(this.discard),
        catapult: catapult ?? this.catapult,
      );
}

class DefenderState {
  final int stone;
  final int food;
  final int gold;
  final List<DefenderCard> deck;
  final List<DefenderCard> hand;
  final List<DefenderCard> discard;
  final int wall;

  const DefenderState({
    required this.stone,
    required this.food,
    required this.gold,
    required this.deck,
    required this.hand,
    required this.discard,
    required this.wall,
  });

  Map<String, dynamic> toJson() => {
        'stone': stone,
        'food': food,
        'gold': gold,
        'deck': deck.map((c) => c.name).toList(),
        'hand': hand.map((c) => c.name).toList(),
        'discard': discard.map((c) => c.name).toList(),
        'wall': wall,
      };

  factory DefenderState.fromJson(Map<String, dynamic> json) => DefenderState(
        stone: json['stone'] as int,
        food: json['food'] as int,
        gold: json['gold'] as int,
        deck: (json['deck'] as List)
            .map((s) => DefenderCard.values.byName(s as String))
            .toList(),
        hand: (json['hand'] as List)
            .map((s) => DefenderCard.values.byName(s as String))
            .toList(),
        discard: (json['discard'] as List)
            .map((s) => DefenderCard.values.byName(s as String))
            .toList(),
        wall: json['wall'] as int,
      );

  DefenderState copyWith({
    int? stone,
    int? food,
    int? gold,
    List<DefenderCard>? deck,
    List<DefenderCard>? hand,
    List<DefenderCard>? discard,
    int? wall,
  }) =>
      DefenderState(
        stone: stone ?? this.stone,
        food: food ?? this.food,
        gold: gold ?? this.gold,
        deck: deck ?? List.from(this.deck),
        hand: hand ?? List.from(this.hand),
        discard: discard ?? List.from(this.discard),
        wall: wall ?? this.wall,
      );
}

class DefenderConfig {
  final int archers;
  final int balista;
  final int fireArrows;
  final List<int> fireArrowsDot;

  const DefenderConfig({
    required this.archers,
    required this.balista,
    required this.fireArrows,
    required this.fireArrowsDot,
  });

  Map<String, dynamic> toJson() => {
        'archers': archers,
        'balista': balista,
        'fireArrows': fireArrows,
        'fireArrowsDot': fireArrowsDot,
      };

  factory DefenderConfig.fromJson(Map<String, dynamic> json) => DefenderConfig(
        archers: json['archers'] as int,
        balista: json['balista'] as int,
        fireArrows: json['fireArrows'] as int,
        fireArrowsDot: (json['fireArrowsDot'] as List).cast<int>(),
      );
}

class AIConfig {
  final int sight;
  final double noise;

  const AIConfig({
    required this.sight,
    required this.noise,
  });

  Map<String, dynamic> toJson() => {
        'sight': sight,
        'noise': noise,
      };

  factory AIConfig.fromJson(Map<String, dynamic> json) => AIConfig(
        sight: json['sight'] as int,
        noise: (json['noise'] as num).toDouble(),
      );
}

class GameState {
  final int turn;
  final Phase phase;
  final int wallMax;
  final int catapultMax;
  final PlayerState attacker;
  final DefenderState defender;
  final DefenderConfig defenderConfig;
  final AIConfig aiConfig;
  final int infantry;
  final List<int> gateFire;
  final List<int> catapultFire;
  final List<String> log;
  final int playerTurnsCompleted;
  final int defenderTurnsCompleted;
  final bool discardMode;

  const GameState({
    required this.turn,
    required this.phase,
    required this.wallMax,
    required this.catapultMax,
    required this.attacker,
    required this.defender,
    required this.defenderConfig,
    required this.aiConfig,
    required this.infantry,
    required this.gateFire,
    required this.catapultFire,
    required this.log,
    required this.playerTurnsCompleted,
    required this.defenderTurnsCompleted,
    required this.discardMode,
  });

  Map<String, dynamic> toJson() => {
        'turn': turn,
        'phase': phase.name,
        'wallMax': wallMax,
        'catapultMax': catapultMax,
        'attacker': attacker.toJson(),
        'defender': defender.toJson(),
        'defenderConfig': defenderConfig.toJson(),
        'aiConfig': aiConfig.toJson(),
        'infantry': infantry,
        'gateFire': gateFire,
        'catapultFire': catapultFire,
        'log': log,
        'playerTurnsCompleted': playerTurnsCompleted,
        'defenderTurnsCompleted': defenderTurnsCompleted,
        'discardMode': discardMode,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        turn: json['turn'] as int,
        phase: Phase.values.byName(json['phase'] as String),
        wallMax: json['wallMax'] as int,
        catapultMax: json['catapultMax'] as int,
        attacker: PlayerState.fromJson(json['attacker'] as Map<String, dynamic>),
        defender:
            DefenderState.fromJson(json['defender'] as Map<String, dynamic>),
        defenderConfig: DefenderConfig.fromJson(
            json['defenderConfig'] as Map<String, dynamic>),
        aiConfig: AIConfig.fromJson(json['aiConfig'] as Map<String, dynamic>),
        infantry: json['infantry'] as int,
        gateFire: (json['gateFire'] as List).cast<int>(),
        catapultFire: (json['catapultFire'] as List).cast<int>(),
        log: (json['log'] as List).cast<String>(),
        playerTurnsCompleted: json['playerTurnsCompleted'] as int,
        defenderTurnsCompleted: json['defenderTurnsCompleted'] as int,
        discardMode: json['discardMode'] as bool,
      );

  GameState copyWith({
    int? turn,
    Phase? phase,
    int? wallMax,
    int? catapultMax,
    PlayerState? attacker,
    DefenderState? defender,
    DefenderConfig? defenderConfig,
    AIConfig? aiConfig,
    int? infantry,
    List<int>? gateFire,
    List<int>? catapultFire,
    List<String>? log,
    int? playerTurnsCompleted,
    int? defenderTurnsCompleted,
    bool? discardMode,
  }) =>
      GameState(
        turn: turn ?? this.turn,
        phase: phase ?? this.phase,
        wallMax: wallMax ?? this.wallMax,
        catapultMax: catapultMax ?? this.catapultMax,
        attacker: attacker ?? this.attacker,
        defender: defender ?? this.defender,
        defenderConfig: defenderConfig ?? this.defenderConfig,
        aiConfig: aiConfig ?? this.aiConfig,
        infantry: infantry ?? this.infantry,
        gateFire: gateFire ?? List.from(this.gateFire),
        catapultFire: catapultFire ?? List.from(this.catapultFire),
        log: log ?? List.from(this.log),
        playerTurnsCompleted: playerTurnsCompleted ?? this.playerTurnsCompleted,
        defenderTurnsCompleted:
            defenderTurnsCompleted ?? this.defenderTurnsCompleted,
        discardMode: discardMode ?? this.discardMode,
      );
}
