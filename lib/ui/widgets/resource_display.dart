import 'package:flutter/material.dart';
import '../theme.dart';

class ResourceDisplay extends StatelessWidget {
  final int stone;
  final int food;
  final int gold;

  const ResourceDisplay({
    super.key,
    required this.stone,
    required this.food,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildResource('🪨', 'stone', stone)),
        const SizedBox(width: 8),
        Expanded(child: _buildResource('🍖', 'food', food)),
        const SizedBox(width: 8),
        Expanded(child: _buildResource('🪙', 'gold', gold)),
      ],
    );
  }

  Widget _buildResource(String icon, String label, int value) {
    String assetPath;
    switch (label) {
      case 'stone':
        assetPath = 'assets/art/ui/resource_stone.png';
        break;
      case 'food':
        assetPath = 'assets/art/ui/resource_food.png';
        break;
      case 'gold':
        assetPath = 'assets/art/ui/resource_gold.png';
        break;
      default:
        assetPath = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: SiegeTheme.panel.withOpacity(0.85),
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetPath.isNotEmpty)
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: SiegeTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
