import 'cards.dart';

abstract class Move {
  Map<String, dynamic> toJson();
}

class PlayAttackerCard extends Move {
  final AttackerCard card;
  final int handIndex;

  PlayAttackerCard({required this.card, required this.handIndex});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'playAttacker',
        'card': card.name,
        'handIndex': handIndex,
      };
}

class DiscardAttackerCard extends Move {
  final int handIndex;

  DiscardAttackerCard({required this.handIndex});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'discardAttacker',
        'handIndex': handIndex,
      };
}

class PlayDefenderCard extends Move {
  final DefenderCard card;
  final int handIndex;

  PlayDefenderCard({required this.card, required this.handIndex});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'playDefender',
        'card': card.name,
        'handIndex': handIndex,
      };
}

class DiscardDefenderCard extends Move {
  final int handIndex;

  DiscardDefenderCard({required this.handIndex});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'discardDefender',
        'handIndex': handIndex,
      };
}
