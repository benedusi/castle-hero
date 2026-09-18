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
        opacity: canPlay ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 150),
        child: Container(
          // Production cards have baked-in rims - no second border frame
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Soft amber glow when playable
            boxShadow: canPlay
                ? [
                    BoxShadow(
                      color: SiegeTheme.attacker.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card art image - use contain for varying card sizes
                Image.asset(
                  _getCardAssetPath(),
                  fit: BoxFit.contain,
                ),
                // Dim overlay for unaffordable cards
                if (!canPlay)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
