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
    // Map card enum to asset path
    switch (card.card) {
      case AttackerCard.fire:
        return 'assets/art/cards/fire.png';
      case AttackerCard.volley:
        return 'assets/art/cards/volley.png';
      case AttackerCard.infantry:
        return 'assets/art/cards/infantry.png';
      case AttackerCard.fireball:
        return 'assets/art/cards/fireball.png';
      case AttackerCard.mercenaries:
        return 'assets/art/cards/mercenaries.png';
      case AttackerCard.cleanse:
        return 'assets/art/cards/cleanse.png';
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card art image
                Image.asset(
                  _getCardAssetPath(),
                  fit: BoxFit.cover,
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
    );
  }
}
