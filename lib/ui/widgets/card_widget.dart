import 'package:flutter/material.dart';
import '../../engine/cards.dart';
import '../theme.dart';

class CardWidget extends StatelessWidget {
  final AttackerCardDef card;
  final bool canPlay;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.canPlay,
    this.onTap,
  });

  String _getCardAssetPath() {
    // Map card enum to production asset path
    switch (card.card) {
      case AttackerCard.fire:
        return 'assets/art/production/cards/card-fire.png';
      case AttackerCard.volley:
        return 'assets/art/production/cards/card-volley.png';
      case AttackerCard.infantry:
        return 'assets/art/production/cards/card-infantry.png';
      case AttackerCard.fireball:
        return 'assets/art/production/cards/card-fireball.png';
      case AttackerCard.mercenaries:
        return 'assets/art/production/cards/card-mercenaries.png';
      case AttackerCard.cleanse:
        return 'assets/art/production/cards/card-cleanse-attacker.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canPlay ? onTap : null,
      child: AnimatedOpacity(
        opacity: canPlay ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: canPlay ? SiegeTheme.attacker : SiegeTheme.line,
              width: canPlay ? 2 : 1,
            ),
            boxShadow: canPlay
                ? [
                    BoxShadow(
                      color: SiegeTheme.attacker.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(
              color: SiegeTheme.background,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Card art image - use contain for varying card sizes
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      _getCardAssetPath(),
                      fit: BoxFit.contain, // Contain, not cover - cards have varying sizes
                    ),
                  ),
                  // Unaffordable overlay
                  if (!canPlay)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
