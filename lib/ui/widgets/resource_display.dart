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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: SiegeTheme.panel,
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SiegeTheme.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$icon $label',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: SiegeTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
