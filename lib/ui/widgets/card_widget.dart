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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canPlay ? onTap : null,
      child: AnimatedOpacity(
        opacity: canPlay ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SiegeTheme.panel,
            border: Border.all(
              color: canPlay ? SiegeTheme.line : SiegeTheme.line,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.name,
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30,
                        color: SiegeTheme.ink,
                      ),
                    ),
                  ),
                  _buildTierDot(),
                ],
              ),
              const SizedBox(height: 5),
              _buildCost(),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  card.desc,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: SiegeTheme.muted,
                    height: 1.35,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierDot() {
    final color = card.tier == 1
        ? SiegeTheme.good
        : card.tier == 2
            ? SiegeTheme.gold
            : SiegeTheme.attacker;

    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCost() {
    final parts = <String>[];
    if (card.cost.stone > 0) parts.add('${card.cost.stone}🪨');
    if (card.cost.food > 0) parts.add('${card.cost.food}🍖');
    if (card.cost.gold > 0) parts.add('${card.cost.gold}🪙');

    return Text(
      parts.join(' '),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: canPlay ? SiegeTheme.ink : SiegeTheme.muted,
      ),
    );
  }
}
